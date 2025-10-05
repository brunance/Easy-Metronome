# 🎵 Sistema de Compassos - EasyMetronome

## Visão Geral

O metrônomo agora suporta diferentes fórmulas de compasso (time signatures), com acentuação automática no primeiro tempo de cada compasso.

## Como Funciona

### Acentuação
- **Primeiro tempo**: Som mais agudo (1200 Hz) - indica o início do compasso
- **Outros tempos**: Som normal (1000 Hz)

### Indicador Visual
Círculos pequenos mostram visualmente qual tempo está tocando:
- **Preenchido**: Tempo atual
- **Vazio**: Tempos restantes

## Compassos Disponíveis

### 4/4 - Comum
```
1  2  3  4  | 1  2  3  4
↑           ↑
```
- **Uso**: Música popular, rock, pop
- **Exemplos**: Maioria das músicas modernas
- **Acentuação**: Tempo 1 forte, tempo 3 médio

### 3/4 - Valsa
```
1  2  3  | 1  2  3
↑        ↑
```
- **Uso**: Valsas, música clássica
- **Exemplos**: "The Blue Danube", "Moon River"
- **Acentuação**: Tempo 1 forte

### 2/4 - Marcha
```
1  2  | 1  2
↑     ↑
```
- **Uso**: Marchas, polcas
- **Exemplos**: Músicas militares
- **Acentuação**: Tempo 1 forte

### 6/8 - Composto
```
1  2  3  4  5  6  | 1  2  3  4  5  6
↑                 ↑
```
- **Uso**: Jigs, tarantellas, baladas
- **Exemplos**: "Norwegian Wood", "We Are The Champions"
- **Acentuação**: Tempo 1 forte, tempo 4 médio

### 5/4 - Cinco por Quatro
```
1  2  3  4  5  | 1  2  3  4  5
↑              ↑
```
- **Uso**: Jazz, rock progressivo
- **Exemplos**: "Take Five" (Dave Brubeck), "Mission Impossible"
- **Acentuação**: Tempo 1 forte

### 7/8 - Sete por Oito
```
1  2  3  4  5  6  7  | 1  2  3  4  5  6  7
↑                    ↑
```
- **Uso**: Música balcânica, rock progressivo
- **Exemplos**: "Money" (Pink Floyd), músicas turcas
- **Acentuação**: Tempo 1 forte

## Implementação Técnica

### TimeSignature.swift
```swift
struct TimeSignature {
    let beats: Int        // Número de tempos
    let noteValue: Int    // Valor da nota (4 = semínima, 8 = colcheia)
    let name: String      // Nome descritivo
}
```

### MetronomeEngine
- **Dois sons diferentes**: Normal (1000 Hz) e Acentuado (1200 Hz)
- **Contador de tempos**: `currentBeat` rastreia o tempo atual
- **Reset automático**: Volta ao tempo 1 após completar o compasso

### Fluxo de Execução
1. Usuário seleciona compasso
2. Timer dispara a cada batida
3. Engine verifica se é o primeiro tempo
4. Toca som acentuado (tempo 1) ou normal (outros tempos)
5. Atualiza indicador visual
6. Incrementa contador de tempos

## Uso no Código

### Selecionar Compasso
```swift
metronome.setTimeSignature(.waltz)  // 3/4
metronome.setTimeSignature(.common) // 4/4
```

### Acessar Informações
```swift
let beats = metronome.timeSignature.beats
let current = metronome.currentBeat
let description = metronome.timeSignature.description // "4/4"
```

## Adicionar Novos Compassos

1. Abra `TimeSignature.swift`
2. Adicione uma nova constante estática:
```swift
static let nineFour = TimeSignature(
    beats: 9, 
    noteValue: 4, 
    name: "Nove por Quatro"
)
```
3. Adicione ao array `allSignatures`:
```swift
static let allSignatures: [TimeSignature] = [
    .common, .waltz, .march, .compound, 
    .fiveFour, .sevenEight, .nineFour  // Novo!
]
```

## Melhorias Futuras

### Subdivisões
Adicionar suporte para subdivisões (semicolcheias, tercinas):
- 4/4 com subdivisão de 4 (16 cliques por compasso)
- 6/8 com subdivisão de 2 (12 cliques por compasso)

### Acentuação Personalizada
Permitir padrões customizados:
- 7/8 pode ser 2+2+3 ou 3+2+2
- Usuário define quais tempos são acentuados

### Polirritmia
Suporte para múltiplos compassos simultâneos:
- 3 contra 4
- 5 contra 7

## Teoria Musical

### Numerador (Beats)
Indica quantos tempos há no compasso.

### Denominador (Note Value)
Indica qual nota recebe um tempo:
- **4** = Semínima (quarter note)
- **8** = Colcheia (eighth note)
- **2** = Mínima (half note)

### Compassos Simples vs Compostos
- **Simples**: Cada tempo se divide em 2 (2/4, 3/4, 4/4)
- **Compostos**: Cada tempo se divide em 3 (6/8, 9/8, 12/8)

## Referências

- [Time Signatures - Music Theory](https://www.musictheory.net/lessons/12)
- [Compound Meters](https://www.musictheory.net/lessons/13)
- [Irregular Meters](https://en.wikipedia.org/wiki/Metre_(music)#Irregular_meters)
