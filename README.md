# EasyMetronome 🎵

Um aplicativo de metrônomo simples e elegante para iOS, desenvolvido em SwiftUI.

## Características

- ✨ Interface moderna e minimalista
- 🎯 Ajuste de BPM de 40 a 240
- ⚡ Controles rápidos: +1, -1, +10, -10 BPM
- 🎨 Animação visual sincronizada com o ritmo
- 🔊 Som de clique sintetizado de alta qualidade
- 🎵 Suporte para diferentes compassos (4/4, 3/4, 2/4, 6/8, 5/4, 7/8)
- 🎨 Sistema de temas (Rosa, Claro, Escuro)
- 📊 Indicador visual de tempos
- 🔔 Acentuação no primeiro tempo
- 📱 Suporte para iOS

## Arquitetura

### MetronomeEngine.swift
Classe principal que gerencia toda a lógica do metrônomo:

- **Audio Setup**: Configuração da sessão de áudio e geração do som de clique
- **Playback Control**: Controle de play/pause/toggle
- **BPM Control**: Métodos para ajustar o BPM com validação de limites
- **Timer Management**: Gerenciamento do timer para tocar o som no ritmo correto

### ContentView.swift
Interface do usuário organizada em componentes reutilizáveis:

- **backgroundGradient**: Gradiente de fundo escuro
- **titleView**: Título do app
- **bpmIndicator**: Indicador circular grande com animação de pulso
- **primaryControls**: Botões principais (-1, Play/Pause, +1)
- **secondaryControls**: Botões de ajuste rápido (-10, +10)
- **bpmRangeLabel**: Label mostrando o range de BPM disponível

## Uso

1. Abra o app
2. **Selecione o compasso** tocando no botão com a fórmula de compasso (ex: 4/4)
3. Use os botões **+** e **-** para ajustar o BPM em 1 unidade
4. Use os botões **+10** e **-10** para ajustes rápidos
5. Pressione o botão central para **iniciar/pausar** o metrônomo
6. Observe os **indicadores de tempo** que mostram qual tempo está tocando
7. O **primeiro tempo** de cada compasso tem um som mais agudo (acentuado)
8. Toque no botão **🌓** no canto superior direito para alternar entre temas

## Tecnologias

- SwiftUI para interface
- AVFoundation para áudio
- Combine para gerenciamento de estado
- Timer para sincronização

## Estrutura de Código

```
EasyMetronome/
├── EasyMetronomeApp.swift    # Entry point do app
├── MetronomeView.swift        # Interface do usuário
├── MetronomeEngine.swift      # Lógica do metrônomo
├── Models/
│   └── TimeSignature.swift   # Definição de compassos
├── Theme/
│   └── ColorTheme.swift      # Sistema de temas
└── Assets.xcassets/          # Recursos visuais e paletas de cores
```

## Compassos Disponíveis

- **4/4** (Comum) - Compasso mais usado em música popular
- **3/4** (Valsa) - Compasso de valsa
- **2/4** (Marcha) - Compasso de marcha
- **6/8** (Composto) - Compasso composto
- **5/4** - Compasso irregular de 5 tempos
- **7/8** - Compasso irregular de 7 tempos

## Melhorias Futuras

- [x] Suporte para diferentes compassos (4/4, 3/4, etc.)
- [x] Modo escuro/claro
- [ ] Sons de clique personalizáveis
- [ ] Presets de BPM para diferentes estilos musicais
- [ ] Histórico de BPMs usados
- [ ] Tap tempo para definir BPM
- [ ] Subdivisões (semicolcheias, tercinas)
- [ ] Padrões de acentuação personalizados

## Requisitos

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Licença

Projeto pessoal desenvolvido por Bruno França do Prado.
