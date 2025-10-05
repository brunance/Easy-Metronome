#!/bin/bash

# Script para rodar SwiftLint no projeto EasyMetronome

echo "🔍 Rodando SwiftLint..."
echo ""

# Verifica se SwiftLint está instalado
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint não está instalado!"
    echo "Instale com: brew install swiftlint"
    exit 1
fi

# Roda o linter
swiftlint lint EasyMetronome

# Captura o código de saída
EXIT_CODE=$?

echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Nenhuma violação encontrada!"
else
    echo "⚠️  Violações encontradas. Execute 'swiftlint --fix EasyMetronome' para corrigir automaticamente."
fi

exit $EXIT_CODE
