org 100h ;diz ao assembler que esse código é um programa .COM

section .data
;Varipaveis
    player_x dw 160
    player_y dw 100
    debug_color db 01h  ; Cor azul padrão

    ; Sprite do persongem jogável
    ghost_sprite:
        db 0FFh, 0C3h, 0A5h, 0BDh, 0BDh, 081h, 0C3h, 0FFh

section .text ; sessão onde o código fica
start: ;função ou rotulo de inicio
    ; estrutura do código
    mov ah, 00h ; setar video
    mov al, 13h
    int 10h ;mudar para video

    mov ax, 0A000h ; adicionando uma posição de memoria ao ax
    mov es, ax ; apontar ES para a memoria de video



game_loop:
        ; Logica para ler tecla e atualizar posição
       
    .delay_before_input:
        nop
        loop .delay_before_input
        
        ; Agora sim verifica o teclado
    check_key:
        mov ah, 01h       ; Função: "Verificar se tecla disponível"
        int 16h           ; Chama a interrupção do teclado
        jz no_key         ; Se ZF=1 (nenhuma tecla), pula para 'no_key'

        ; Se chegou aqui, é porque uma tecla ESTÁ disponível (ZF=0)
        mov ah, 00h       ; Função: "Ler tecla"
        int 16h           ; AX agora contém o código da tecla (AH = scan code, AL = caractere ASCII)

        ; Compara o scan code (em AH) com os códigos das setas e ESC
        cmp ah, 48h       ; Scan code da seta para CIMA?
        je move_up
        cmp ah, 50h       ; Scan code da seta para BAIXO?
        je move_down
        cmp ah, 4Bh       ; Scan code da seta para ESQUERDA?
        je move_left
        cmp ah, 4Dh       ; Scan code da seta para DIREITA?
        je move_right
        cmp ah, 01h       ; Scan code da tecla ESC?
        je exit           ; Se for ESC, vai para a saída
        ; Se for outra tecla, não faz nada e continua em 'no_key'
        jmp no_key

    move_up:
        dec word [player_y]
        mov byte [debug_color], 2Ah  ; Verde
        jmp key_processed

    move_down:
        inc word [player_y]
        mov byte [debug_color], 0Eh  ; Amarelo
        jmp key_processed

    move_left:
        dec word [player_x]
        mov byte [debug_color], 04h  ; Vermelho
        jmp key_processed

    move_right:
        inc word [player_x]
        mov byte [debug_color], 09h  ; Azul claro
        jmp key_processed
    key_processed:
        ; Limpa o buffer do teclado APENAS após processar uma tecla
        ; Isso evita que a mesma tecla seja processada múltiplas vezes
        mov ah, 01h    ; Verifica se há mais teclas no buffer
        int 16h
        jz .buffer_clean  ; Se não há, sai
        mov ah, 00h    ; Se há, remove a tecla
        int 16h
        jmp key_processed ; Verifica novamente (até esvaziar completamente)
    .buffer_clean:
        jmp no_key

    no_key:
        ; ----- LIMPAR A TELA (Pintar TUDO de preto) -----
        ; Vamos usar a instrução REP STOSB para preencher a memória de vídeo rapidamente
        mov ax, 0A000h  ; Garantir que ES aponta para a memória de vídeo
        mov es, ax
        xor di, di      ; DI = 0 (início da memória de vídeo)
        xor al, al      ; AL = 0 (cor preta)
        mov cx, 64000   ; CX = 320*200 = 64000 pixels
        rep stosb       ; Preenche CX bytes com o valor em AL

        ; Desenhar sprite do personagem
        mov di, [player_y]  ; Y
        imul di, 320        ; DI = Y * 320
        add di, [player_x]  ; DI = (Y * 320) + X
        mov si, ghost_sprite ; SI aponta para os dados do sprite
        call draw_sprite

        ; ----- PAUSA -----
        mov dx, 2000
    .delay_loop:
        nop
        nop
        nop
        nop
        dec dx
        jnz .delay_loop

        
        jmp game_loop

draw_sprite: ; funçao para desenhar o persongem na tela, entrada SI: offset dos dados do sprite, DI: posicção inicial na memoria de vídeo
    pusha
    push es
   

    mov cx, 8 ; oito linhas de altura
    .next_line:
        push di ; salva a posição inicial da linha
        mov dx, 8 ; 8 pixels por linha
        lodsb
        mov bl, al ; guarda em bl para a verificação bit a bit

        .next_pixel:
            shl bl, 1 ; Desloca BL para a esquerda, coloca o bit mais significativo no Carry flag
            jc .draw_blue ; se Carry flag = 1, desenha azul, se for 0 desenha preto
            mov byte [es:di], 00h
            jmp .pixel_done

            .draw_blue:
            mov al, [debug_color] ; usa a cor do debug
            mov [es:di], al

            .pixel_done:
            inc di ; próximo píxel na mesma linha
            dec dx
            jnz .next_pixel
        
        
        pop di ; recupera a posição inicial da linha
        add di, 320 ; pula para a próxima linha
        loop .next_line

    popa
    pop es
    ret


    exit:
    ;final
    mov ah, 00h ; voltar para o modo texto e terminar o jogo
    mov al, 03h
    int 10h
    mov ax, 4C00h ; função do DOS para determinar um programa
    int 21h ; chama a interrupção do sistema


