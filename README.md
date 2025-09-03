# Assembly RPG DOS

Um jogo RPG simples desenvolvido em Assembly x86 para MS-DOS, criado como projeto de aprendizado.

## 🎮 Status Atual
- [x] Modo gráfico 13h inicializado
- [x] Controle de personagem com teclado
- [x] Sprite 8x8 do personagem
- [x] Game loop funcional

## 🛠️ Como Compilar e Executar
```bash
nasm src/meurpg.asm -o bin/meurpg.com
dosbox bin/meurpg.com