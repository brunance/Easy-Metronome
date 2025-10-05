# EasyMetronome 🎵

Um aplicativo de metrônomo simples e elegante para iOS, desenvolvido em SwiftUI.

## Características

- ✨ Interface moderna e minimalista
- 🎯 Ajuste de BPM de 40 a 240
- ⚡ Controles rápidos: +1, -1, +10, -10 BPM
- 🎨 Animação visual sincronizada com o ritmo
- 🔊 Som de clique sintetizado de alta qualidade
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
2. Use os botões **+** e **-** para ajustar o BPM em 1 unidade
3. Use os botões **+10** e **-10** para ajustes rápidos
4. Pressione o botão central para iniciar/pausar o metrônomo
5. O círculo pulsará no ritmo do BPM selecionado

## Tecnologias

- SwiftUI para interface
- AVFoundation para áudio
- Combine para gerenciamento de estado
- Timer para sincronização

## Estrutura de Código

```
EasyMetronome/
├── EasyMetronomeApp.swift    # Entry point do app
├── ContentView.swift          # Interface do usuário
├── MetronomeEngine.swift      # Lógica do metrônomo
└── Assets.xcassets/          # Recursos visuais
```

## Melhorias Futuras

- [ ] Suporte para diferentes compassos (4/4, 3/4, etc.)
- [ ] Sons de clique personalizáveis
- [ ] Presets de BPM para diferentes estilos musicais
- [ ] Modo escuro/claro
- [ ] Histórico de BPMs usados
- [ ] Tap tempo para definir BPM

## Requisitos

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Licença

Projeto pessoal desenvolvido por Bruno França do Prado.
