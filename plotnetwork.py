import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, ax = plt.subplots(figsize=(10, 12))
ax.set_xlim(0, 10)
ax.set_ylim(0, 20)
ax.axis('off')

conv_color = '#4C72B0'
fc_color = '#55A868'
output_color = '#C44E52'
input_color = '#8172B2'

layers = [
    {'y': 18, 'label': 'Input\n128×128×1', 'color': input_color},
    {'y': 16, 'label': 'Conv1\n16 filters\n3×3, stride 2', 'color': conv_color},
    {'y': 14, 'label': 'Conv2\n32 filters\n3×3, stride 2', 'color': conv_color},
    {'y': 12, 'label': 'Conv3\n64 filters\n3×3, stride 2', 'color': conv_color},
    {'y': 10, 'label': 'Fully Connected\n128 units\nReLU + Dropout 50%', 'color': fc_color},
    {'y': 8, 'label': 'Output Layer\nSoftmax\n6 Classes', 'color': output_color}
]

for layer in layers:
    rect = patches.FancyBboxPatch((3, layer['y']), 4, 1.5,
                                  boxstyle="round,pad=0.1", 
                                  linewidth=2,
                                  facecolor=layer['color'],
                                  edgecolor='black')
    ax.add_patch(rect)
    ax.text(5, layer['y'] + 0.75, layer['label'], fontsize=15, ha='center', va='center', color='white')

for i in range(len(layers) - 1):
    ax.annotate('', xy=(5, layers[i+1]['y'] + 1.5), xytext=(5, layers[i]['y']), 
                arrowprops=dict(arrowstyle='->', lw=2, color='gray'))

plt.title('Stylized CNN Architecture for Modulation Classification', fontsize=14, pad=20)

plt.tight_layout()
plt.savefig("stylized_network_architecture.png", dpi=600)
plt.show()
