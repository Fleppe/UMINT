import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, models, transforms
from torch.utils.data import DataLoader, Subset
import numpy as np
import matplotlib.pyplot as plt
import time
import copy
from datetime import timedelta
import random

# conf
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
NUM_EPOCHS = 30
BATCH_SIZE = 64
LR =  1e-4
NUM_RUNS = 3
AUGMENT = True
MODEL_NAMES = ["resnet34"] 
MODES = ["transfer", "scratch"]
KEEP_CLASSES = ["apple_pie", "caesar_salad", "clam_chowder", "edamame", "french_fries",
                "hamburger", "hot_dog", "ice_cream", "sushi", "waffles"]

data_transforms = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

augment_transforms = transforms.Compose([
    transforms.Resize(256),
    transforms.RandomCrop(224),          
    transforms.RandomHorizontalFlip(),
    transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2, hue=0.1),
    transforms.RandomRotation(15),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])
# uprava datasetu
def get_data():
    print(f"\n[INFO] Sťahujem/Načítavam Food101 dataset na {DEVICE}...")

    if AUGMENT:
        full_train_aug  = datasets.Food101(root='./data', split='train', download=True,  transform=augment_transforms)
        full_train_eval = datasets.Food101(root='./data', split='train', download=False, transform=data_transforms)
        full_test       = datasets.Food101(root='./data', split='test',  download=True,  transform=data_transforms)
    else:
        full_train_aug  = datasets.Food101(root='./data', split='train', download=True,  transform=data_transforms)
        full_train_eval = datasets.Food101(root='./data', split='train', download=False, transform=data_transforms)
        full_test       = datasets.Food101(root='./data', split='test',  download=True,  transform=data_transforms)

    # update indeces of the subset of classes
    def filter_subset(dataset):
        c_to_i = {dataset.classes[i]: i for i in range(len(dataset.classes))}
        target_ids = [c_to_i[cls] for cls in KEEP_CLASSES]
        indices = [i for i, lbl in enumerate(dataset._labels) if lbl in target_ids]
        mapping = {old: new for new, old in enumerate(sorted(target_ids))}
        new_labels = np.array(dataset._labels).copy()
        for i in indices:
            new_labels[i] = mapping[dataset._labels[i]]
        dataset._labels = new_labels.tolist()
        return indices

    indices  = filter_subset(full_train_aug)
    random.shuffle(indeces)
    
    tr_sz = int(0.8 * len(indices))
    train_ds = Subset(full_train_aug,  indices[:tr_sz])
    val_ds   = Subset(full_train_eval, indices[tr_sz:])

    test_indices = filter_subset(full_test)
    test_ds = Subset(full_test, test_indices)

    return train_ds, val_ds, test_ds

train_ds, val_ds, test_ds = get_data()

train_loader = DataLoader(train_ds, batch_size=BATCH_SIZE, shuffle=True, num_workers=4, pin_memory=True)
val_loader = DataLoader(val_ds, batch_size=BATCH_SIZE, shuffle=False, num_workers=4, pin_memory=True)
test_loader = DataLoader(test_ds, batch_size=BATCH_SIZE, shuffle=False, num_workers=4, pin_memory=True)
#vizualizacia
def visualize(model, test_dataset, title_prefix):

    model.eval()
    fig, axes = plt.subplots(2, 5, figsize=(20, 11), facecolor='white')
    
    
    idx_to_class = KEEP_CLASSES
    found_indices = []
    
    
    for target_idx in range(10):
        for i in range(len(test_dataset)):
            if test_dataset[i][1] == target_idx:
                found_indices.append(i)
                break
    
    with torch.no_grad():
        for i, idx in enumerate(found_indices):
            ax = axes.flatten()[i]
            img_tensor, label = test_dataset[idx]
            
            input_tensor = img_tensor.unsqueeze(0).to(DEVICE)
            output = model(input_tensor)
            prob = torch.nn.functional.softmax(output, dim=1)
            conf, pred = torch.max(prob, 1)
            
            
            img_show = img_tensor.permute(1, 2, 0).cpu().numpy()
            img_show = np.clip(img_show * [0.229, 0.224, 0.225] + [0.485, 0.456, 0.406], 0, 1)
            
            ax.imshow(img_show)
            true_name = idx_to_class[label]
            pred_name = idx_to_class[pred.item()]
            
            title_text = (f"Skutočnosť: {true_name}\n\n"
                          f"Predikcia: {pred_name}\n\n"
                          f"Istota: {conf.item()*100:.2f}%")
            
            ax.set_title(title_text, fontsize=10, pad=10, color='black')
            ax.axis('off')

    plt.subplots_adjust(hspace=0.6, wspace=0.3, top=0.85)
    plt.show()


def build_model(name, mode):
    is_tl = (mode == "transfer")
    
    if name == "alexnet":
        m = models.alexnet(weights=models.AlexNet_Weights.DEFAULT if is_tl else None)
        if is_tl:
            for p in m.parameters(): p.requires_grad = False
            for p in m.features[10].parameters(): p.requires_grad = True
        num_ftrs = m.classifier[6].in_features
        m.classifier[6] = nn.Linear(num_ftrs, 10)

    elif name == "resnet34":
        m = models.resnet34(weights=models.ResNet34_Weights.DEFAULT if is_tl else None)
        if is_tl:
            for p in m.parameters(): p.requires_grad = False
            for p in m.layer4.parameters(): p.requires_grad = True
        num_ftrs = m.fc.in_features
        m.fc = nn.Linear(num_ftrs, 10)

    elif name == "mobilenet_v2":
        m = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.DEFAULT if is_tl else None)
        if is_tl:
            for p in m.parameters(): p.requires_grad = False
            for p in m.features[18].parameters(): p.requires_grad = True
        num_ftrs = m.classifier[1].in_features
        m.classifier[1] = nn.Linear(num_ftrs, 10)
        
    return m.to(DEVICE)


def train_and_test(model, mode):
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(filter(lambda p: p.requires_grad, model.parameters()), 
                           lr=LR)
    
    history = {'t_loss': [], 'v_loss': [], 't_acc': [], 'v_acc': []}
    
    patience = 6
    best_val_acc = 0.0
    best_model_wts = copy.deepcopy(model.state_dict())
    epochs_no_improve = 0
    start_time = time.time()

    for epoch in range(NUM_EPOCHS):
        epoch_start = time.time()
        
        model.train()
        tr_loss, tr_corr = 0.0, 0
        for imgs, lbls in train_loader:
            imgs, lbls = imgs.to(DEVICE), lbls.to(DEVICE)
            optimizer.zero_grad()
            out = model(imgs)
            loss = criterion(out, lbls)
            loss.backward()
            optimizer.step()
            tr_loss += loss.item() * imgs.size(0)
            tr_corr += (out.argmax(1) == lbls).sum().item()

        model.eval()
        v_loss, v_corr = 0.0, 0
        with torch.no_grad():
            for imgs, lbls in val_loader:
                imgs, lbls = imgs.to(DEVICE), lbls.to(DEVICE)
                out = model(imgs)
                v_loss += criterion(out, lbls).item() * imgs.size(0)
                v_corr += (out.argmax(1) == lbls).sum().item()
        
        t_acc_epoch = tr_corr / len(train_ds)
        t_loss_epoch = tr_loss / len(train_ds)
        val_acc = v_corr / len(val_ds)
        val_loss_epoch = v_loss / len(val_ds)

        history['t_loss'].append(t_loss_epoch)
        history['v_loss'].append(val_loss_epoch)
        history['t_acc'].append(t_acc_epoch)
        history['v_acc'].append(val_acc)
        
        
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            best_model_wts = copy.deepcopy(model.state_dict())
            epochs_no_improve = 0
            status = " [NEW BEST]"
        else:
            epochs_no_improve += 1
            status = f" [No improve: {epochs_no_improve}]"

        epoch_end = time.time()
        print(f"    [Epoch {epoch+1:02d}] "
              f"Train Loss: {t_loss_epoch:.4f} | Train Acc: {t_acc_epoch:.4f} | "
              f"Val Loss: {val_loss_epoch:.4f} | Val Acc: {val_acc:.4f} | "
              f"Time: {epoch_end-epoch_start:.1f}s{status}")

        if epochs_no_improve >= patience:
            print(f"\n[STOP] Early stopping po {epoch+1} epochách.")
            break

    model.load_state_dict(best_model_wts)
    total_time = time.time() - start_time
    
    model.eval()
    te_loss, te_corr = 0.0, 0
    with torch.no_grad():
        for imgs, lbls in test_loader:
            imgs, lbls = imgs.to(DEVICE), lbls.to(DEVICE)
            out = model(imgs)
            te_loss += criterion(out, lbls).item() * imgs.size(0)
            te_corr += (out.argmax(1) == lbls).sum().item()
            
    return history, (te_loss / len(test_ds)), (te_corr / len(test_ds)), total_time

# run exp
results = {m: {mo: [] for mo in MODES} for m in MODEL_NAMES}
overall_start = time.time()

for m_name in MODEL_NAMES:
    print(f"\n{'='*60}\nARCHITECTURE: {m_name.upper()}\n{'='*60}")
    for mode in MODES:
        print(f"\n>>> Mode: {mode.upper()}")
        for r in range(NUM_RUNS):
            print(f"  -> Run {r+1}/{NUM_RUNS}:")
            model = build_model(m_name, mode)
            hist, t_loss, t_acc, r_time = train_and_test(model, mode)
            results[m_name][mode].append({'hist': hist, 'loss': t_loss, 'acc': t_acc})
            
            fig_title = f"Model: {m_name.upper()} | Mód: {mode.upper()} | Run: {r+1}"
            visualize(model, test_ds, fig_title)
            
            print(f"  [DONE] Test Acc: {t_acc*100:.2f}% | Run Time: {str(timedelta(seconds=int(r_time)))}")

# summary table
print(f"\n\n{'#'*60}\n{' FINAL SUMMARY TABLE ':#^60}\n{'#'*60}")
print(f"{'MODEL':<15} | {'MODE':<10} | {'TEST LOSS':<12} | {'TEST ACC':>10} | {'VAL LOSS':<12} | {'VAL ACC':>10} | {'TRAIN LOSS':<12} | {'TRAIN ACC':>10}")
print("-" * 120)

for m_name in MODEL_NAMES:
    for mode in MODES:
        data_list = results[m_name][mode]
        avg_test_loss = np.mean([d['loss'] for d in data_list])
        avg_test_acc  = np.mean([d['acc']  for d in data_list]) * 100
        avg_val_loss   = np.mean([d['hist']['v_loss'][-1] for d in data_list])
        avg_val_acc    = np.mean([d['hist']['v_acc'][-1]  for d in data_list]) * 100
        avg_train_loss = np.mean([d['hist']['t_loss'][-1] for d in data_list])
        avg_train_acc  = np.mean([d['hist']['t_acc'][-1]  for d in data_list]) * 100

        print(f"{m_name:<15} | {mode:<10} | {avg_test_loss:<12.4f} | {avg_test_acc:>9.2f}% "
              f"| {avg_val_loss:<12.4f} | {avg_val_acc:>9.2f}% "
              f"| {avg_train_loss:<12.4f} | {avg_train_acc:>9.2f}%")
        
        h = data_list[0]['hist']
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))
        ax1.plot(h['t_loss'], label='Train')
        ax1.plot(h['v_loss'], label='Val')
        ax1.set_title(f'Loss {m_name}-{mode}')
        ax1.legend(); ax1.grid(True)
        ax2.plot(h['t_acc'], label='Train')
        ax2.plot(h['v_acc'], label='Val')
        ax2.set_title(f'Acc {m_name}-{mode}')
        ax2.legend(); ax2.grid(True)
        plt.savefig(f"plot_{m_name}_{mode}.png")
        plt.close()

print(f"\n[INFO] Celkový čas experimentov: {str(timedelta(seconds=int(time.time() - overall_start)))}")
