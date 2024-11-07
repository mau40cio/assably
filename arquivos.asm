.data
file_input: .asciiz "lista.txt"             # Nome do arquivo de entrada
file_output: .asciiz "lista_ordenada.txt"    # Nome do arquivo de sa�da
buffer: .space 256                          # Buffer para leitura do arquivo (256 bytes por vez)
vetor: .space 4096                          # Vetor para armazenar todo o conte�do do arquivo
msg_read: .asciiz "leu\n"                   # Mensagem de sucesso na leitura
msg_write: .asciiz "imprimiu\n"             # Mensagem de sucesso na escrita

.text
main:
    # Abrir o arquivo de entrada para leitura
    li $v0, 13                              # Syscall para abrir arquivo
    la $a0, file_input                      # Nome do arquivo de entrada
    li $a1, 0                               # Modo de leitura (0 = leitura)
    li $a2, 0                               # Sem permiss�es especiais
    syscall
    move $t0, $v0                           # Salva o descritor do arquivo de entrada em $t0
    bltz $t0, error_open_input              # Se falhar ao abrir o arquivo, v� para o erro

    # Inicializar ponteiros e contadores
    la $t2, vetor                           # Ponteiro para o in�cio do vetor
    li $t3, 0                               # Contador total de bytes lidos

read_file:
    # Ler um bloco de dados do arquivo de entrada
    li $v0, 14                              # Syscall para leitura de arquivo
    move $a0, $t0                           # Descritor do arquivo de entrada
    la $a1, buffer                          # Endere�o do buffer
    li $a2, 256                             # N�mero de bytes a serem lidos
    syscall
    move $t1, $v0                           # N�mero de bytes lidos

    # Se nenhum byte foi lido, final da leitura
    beqz $t1, write_to_output

    # Copiar o conte�do do buffer para o vetor
    la $t4, buffer                          # Ponteiro para o buffer
    li $t5, 0                               # Contador de bytes no loop de c�pia

copy_buffer_to_vector:
    lb $t6, 0($t4)                          # L� um byte do buffer
    sb $t6, 0($t2)                          # Armazena o byte no vetor
    addi $t2, $t2, 1                        # Avan�a o ponteiro do vetor
    addi $t4, $t4, 1                        # Avan�a o ponteiro do buffer
    addi $t5, $t5, 1                        # Incrementa o contador de bytes copiados
    addi $t3, $t3, 1                        # Incrementa o contador total no vetor
    bne $t5, $t1, copy_buffer_to_vector     # Continua copiando at� atingir o n�mero de bytes lidos

    # Voltar para ler o pr�ximo bloco
    j read_file

write_to_output:
    # Abrir o arquivo de sa�da para escrita
    li $v0, 13                              # Syscall para abrir arquivo
    la $a0, file_output                     # Nome do arquivo de sa�da
    li $a1, 1                               # Modo de escrita (1 = escrita)
    li $a2, 0                               # Sem permiss�es especiais
    syscall
    move $t0, $v0                           # Salva o descritor do arquivo de sa�da em $t0
    bltz $t0, error_open_output             # Se falhar ao abrir o arquivo de sa�da, v� para o erro

    # Escrever o conte�do do vetor no arquivo de sa�da
    li $v0, 15                              # Syscall para escrever no arquivo
    move $a0, $t0                           # Descritor do arquivo de sa�da
    la $a1, vetor                           # Endere�o do vetor com os dados
    move $a2, $t3                           # N�mero total de bytes no vetor
    syscall

    # Fechar o arquivo de sa�da
    li $v0, 16                              # Syscall para fechar arquivo
    move $a0, $t0                           # Descritor do arquivo de sa�da
    syscall

    # Imprimir mensagem de sucesso na leitura
    li $v0, 4
    la $a0, msg_read
    syscall

    # Imprimir mensagem de sucesso na escrita
    li $v0, 4
    la $a0, msg_write
    syscall

    j end_program                           # Finaliza o programa

# Tratamento de erro para falha ao abrir o arquivo de entrada
error_open_input:
    li $v0, 4
    la $a0, msg_read
    syscall
    j end_program

# Tratamento de erro para falha ao abrir o arquivo de sa�da
error_open_output:
    li $v0, 4
    la $a0, msg_write
    syscall
    j end_program

end_program:
    li $v0, 10                              # Syscall para sair do programa
    syscall