# 💾 Sistema de Cache de Áudio - EasyMetronome

## Visão Geral

Os sons do metrônomo são gerados uma única vez e salvos no cache local do dispositivo, melhorando significativamente a performance e reduzindo o uso de CPU.

## Localização dos Arquivos

### Diretório de Cache
```
~/Library/Caches/[Bundle ID]/MetronomeSounds/
├── metronome_click.wav    (Som normal - 1000 Hz)
└── metronome_accent.wav   (Som acentuado - 1200 Hz)
```

### Características do Cache
- ✅ **Persistente**: Sobrevive ao fechamento do app
- ✅ **Privado**: Não aparece nos documentos do usuário
- ✅ **Gerenciável**: Sistema pode limpar automaticamente se necessário
- ✅ **Leve**: ~10 KB total (ambos os arquivos)

## Como Funciona

### Primeira Execução
1. App inicia
2. Verifica se os arquivos existem no cache
3. **Não existem** → Gera os sons e salva
4. Carrega os players de áudio
5. Log: `✅ Som criado e salvo em cache: metronome_click.wav`

### Execuções Subsequentes
1. App inicia
2. Verifica se os arquivos existem no cache
3. **Existem** → Carrega diretamente do cache
4. Log: `♻️ Som carregado do cache: metronome_click.wav`

### Benefícios
- **Performance**: Sem geração de áudio a cada inicialização
- **Bateria**: Menos processamento = menos consumo
- **Velocidade**: Inicialização instantânea do metrônomo

## Estrutura dos Arquivos

### Formato WAV
- **Sample Rate**: 44100 Hz
- **Bits per Sample**: 16-bit PCM
- **Channels**: Mono (1 canal)
- **Duration**: 0.05 segundos (50ms)

### Tamanho Aproximado
- `metronome_click.wav`: ~4.4 KB
- `metronome_accent.wav`: ~4.4 KB
- **Total**: ~8.8 KB

## Gerenciamento de Cache

### Verificar Tamanho do Cache
```swift
let cacheSize = metronome.getCacheSize()
print("Cache: \(cacheSize) bytes") // ~8800 bytes
```

### Limpar Cache
```swift
metronome.clearAudioCache()
// Cache será recriado na próxima inicialização
```

### Quando Limpar o Cache?
- Durante desenvolvimento/debug
- Se quiser regenerar os sons com parâmetros diferentes
- Se houver corrupção de arquivo (raro)

## Implementação Técnica

### getCacheDirectory()
```swift
private func getCacheDirectory() -> URL? {
    // Obtém diretório de cache do sistema
    guard let cacheDir = FileManager.default.urls(
        for: .cachesDirectory, 
        in: .userDomainMask
    ).first else { return nil }
    
    // Cria subdiretório específico
    let metronomeCache = cacheDir.appendingPathComponent(
        "MetronomeSounds", 
        isDirectory: true
    )
    
    // Cria se não existir
    if !FileManager.default.fileExists(atPath: metronomeCache.path) {
        try? FileManager.default.createDirectory(
            at: metronomeCache, 
            withIntermediateDirectories: true
        )
    }
    
    return metronomeCache
}
```

### createAudioPlayer()
```swift
private func createAudioPlayer(frequency: Double, fileName: String) -> AVAudioPlayer? {
    let fileURL = cacheDir.appendingPathComponent(fileName)
    
    // Verifica se já existe
    if !FileManager.default.fileExists(atPath: fileURL.path) {
        // Gera e salva
        let wavData = createWAVData(from: audioData, sampleRate: sampleRate)
        try wavData.write(to: fileURL)
    }
    
    // Carrega do cache
    return try AVAudioPlayer(contentsOf: fileURL)
}
```

## Comparação: Antes vs Depois

### Antes (Temporário)
```
Diretório: /tmp/
Persistência: ❌ Limpo pelo sistema
Performance: Regenera a cada execução
Logs: Sempre cria novos arquivos
```

### Depois (Cache)
```
Diretório: ~/Library/Caches/
Persistência: ✅ Mantido entre execuções
Performance: Cria uma vez, usa sempre
Logs: Primeira vez cria, depois reutiliza
```

## Comportamento do Sistema

### iOS Gerenciamento Automático
O iOS pode limpar o cache automaticamente quando:
- Espaço de armazenamento está baixo
- App não é usado por muito tempo
- Sistema precisa liberar memória

Quando isso acontece:
1. Cache é limpo pelo sistema
2. Na próxima execução do app, sons são regenerados
3. Tudo funciona normalmente

### Backup do iCloud
Por padrão, o diretório de cache **NÃO** é incluído em backups do iCloud, economizando espaço na nuvem.

## Debug e Desenvolvimento

### Logs Úteis
```
✅ Som criado e salvo em cache: metronome_click.wav
♻️ Som carregado do cache: metronome_click.wav
🗑️ Cache de áudio limpo
```

### Verificar Cache Manualmente
```bash
# No Simulator
cd ~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Library/Caches/MetronomeSounds

# Listar arquivos
ls -lh

# Ver tamanho total
du -sh .
```

### Forçar Regeneração
Durante desenvolvimento, se você mudar os parâmetros de geração de som:
1. Chame `clearAudioCache()` no init
2. Ou delete manualmente o diretório
3. Ou incremente a versão do arquivo (ex: `metronome_click_v2.wav`)

## Melhorias Futuras

### Versionamento
Adicionar versão aos arquivos para forçar regeneração quando necessário:
```swift
let version = "v1"
let fileName = "metronome_click_\(version).wav"
```

### Compressão
Usar formato comprimido (AAC, MP3) para reduzir ainda mais o tamanho:
- WAV: ~4.4 KB por arquivo
- AAC: ~1 KB por arquivo (75% menor)

### Sons Customizáveis
Permitir usuário escolher diferentes sons e salvá-los no cache:
```
MetronomeSounds/
├── click/
│   ├── wood.wav
│   ├── metal.wav
│   └── digital.wav
└── accent/
    ├── wood.wav
    ├── metal.wav
    └── digital.wav
```

## Boas Práticas

✅ **Sempre verificar existência** antes de gerar  
✅ **Usar subdiretório específico** para organização  
✅ **Adicionar logs** para debug  
✅ **Tratar erros** de I/O adequadamente  
✅ **Documentar formato** dos arquivos  

❌ **Não hardcode paths** absolutos  
❌ **Não assumir** que cache sempre existe  
❌ **Não salvar** dados críticos no cache  
❌ **Não esquecer** de criar diretórios  

## Referências

- [File System Programming Guide](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/)
- [Caches Directory](https://developer.apple.com/documentation/foundation/filemanager/searchpathdirectory/cachesdirectory)
- [AVAudioPlayer](https://developer.apple.com/documentation/avfaudio/avaudioplayer)
