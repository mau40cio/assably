.data
string: .asciiz "245,34,-45,3,-674,0,235"  # String contendo n�meros separados por v�rgulas
.align 2                                   # Alinhamento de mem�ria
numbers: .space 40                         # Espa�o para armazenar at� 10 n�meros (4 bytes cada)
num_count: .word 0                         # Contador de n�meros armazenados
output_str: .space 100                     # Espa�o para a string de sa�da (inclui v�rgulas e terminador nulo)

.text
main:
    # Convers�o de string para inteiros e armazenamento no vetor
    la $t0, string                         # Carrega o endere�o da string original
    la $t1, numbers                        # Endere�o onde os n�meros convertidos ser�o armazenados
    li $t7, 0                              # Flag de n�mero negativo (0 = positivo, 1 = negativo)
    li $t2, 0                              # Inicializa o acumulador do n�mero atual
    li $t8, 0                              # Contador de n�meros convertidos

convert_loop:
    lb $t3, ($t0)                          # Carrega o pr�ximo caractere da string
    beq $t3, $zero, store_last_number      # Se for o fim da string, armazena o �ltimo n�mero

    li $t4, ','                            # Caractere de v�rgula
    beq $t3, $t4, store_number             # Se for v�rgula, armazena o n�mero e continua

    li $t4, '-'                            # Caractere de menos
    beq $t3, $t4, set_negative             # Se for '-', define o n�mero como negativo e continua

    # Converte o caractere ASCII para n�mero
    sub $t3, $t3, 48                       # Subtrai 48 para obter o valor num�rico
    mul $t2, $t2, 10                       # Multiplica o acumulador por 10 para deslocar um d�gito
    add $t2, $t2, $t3                      # Adiciona o d�gito atual ao n�mero acumulado

    addi $t0, $t0, 1                       # Avan�a para o pr�ximo caractere
    j convert_loop                         # Continua o loop

set_negative:
    li $t7, 1                              # Define a flag para indicar n�mero negativo
    addi $t0, $t0, 1                       # Avan�a para o pr�ximo caractere ap�s o '-'
    j convert_loop                         # Continua o loop

store_number:
    # Se o n�mero � negativo, inverte o sinal
    beq $t7, $zero, skip_negate
    sub $t2, $zero, $t2                    # Converte o n�mero para negativo
    li $t7, 0                              # Reseta a flag de negativo

skip_negate:
    # Armazena o n�mero atual no vetor de n�meros
    sw $t2, 0($t1)                         # Armazena o n�mero no vetor em $t1
    addi $t1, $t1, 4                       # Avan�a para o pr�ximo espa�o no vetor
    addi $t8, $t8, 1                       # Incrementa o contador de n�meros
    li $t2, 0                              # Reseta o acumulador do n�mero atual

    addi $t0, $t0, 1                       # Avan�a para o pr�ximo caractere
    j convert_loop                         # Continua o loop

store_last_number:
    # Armazena o �ltimo n�mero acumulado ao final da string
    beq $t2, $zero, sort_numbers           # Se o acumulador estiver vazio, n�o armazena

    # Se o n�mero � negativo, inverte o sinal
    beq $t7, $zero, skip_last_negate
    sub $t2, $zero, $t2                    # Converte o n�mero para negativo
    li $t7, 0                              # Reseta a flag de negativo

skip_last_negate:
    sw $t2, 0($t1)                         # Armazena o �ltimo n�mero no vetor
    addi $t8, $t8, 1                       # Incrementa o contador de n�meros

    sw $t8, num_count                      # Armazena o contador de n�meros em num_count

# Ordena��o dos n�meros com Bubble Sort
sort_numbers:
    la $t1, numbers                        # Reinicia o ponteiro para o in�cio do vetor
    lw $t9, num_count                      # Carrega o n�mero total de elementos

outer_loop:
    addi $t9, $t9, -1                      # Ajusta o limite do loop externo
    li $t0, 0                              # �ndice para o loop interno

inner_loop:
    lw $t2, 0($t1)                         # Carrega o n�mero atual
    lw $t3, 4($t1)                         # Carrega o pr�ximo n�mero

    # Compara e troca se necess�rio
    ble $t2, $t3, skip_swap                # Se $t2 <= $t3, n�o troca
    sw $t3, 0($t1)                         # Coloca o menor n�mero na posi��o atual
    sw $t2, 4($t1)                         # Coloca o maior n�mero na pr�xima posi��o

skip_swap:
    addi $t1, $t1, 4                       # Avan�a para o pr�ximo par
    addi $t0, $t0, 1                       # Incrementa o �ndice
    blt $t0, $t9, inner_loop               # Continua o loop interno

    la $t1, numbers                        # Reinicia o ponteiro para o in�cio do vetor
    bgt $t9, 1, outer_loop                 # Continua o loop externo se necess�rio

# Convers�o dos inteiros ordenados para strings e exibi��o
display_sorted_numbers:
    la $t0, numbers                        # Ponteiro para o in�cio do vetor ordenado
    la $t1, output_str                     # Ponteiro para armazenar a string de sa�da
    lw $t9, num_count                      # Carrega o n�mero total de elementos

convert_to_string_loop:
    lw $a0, 0($t0)                         # Carrega o pr�ximo n�mero do vetor
    addi $t0, $t0, 4                       # Avan�a para o pr�ximo n�mero no vetor
    move $a1, $t1                          # Passa o ponteiro de sa�da para $a1
    jal int_to_string                      # Chama a fun��o para converter o n�mero em string
    move $t1, $v0                          # Atualiza o ponteiro de sa�da para o final da string convertida

    # Adiciona uma v�rgula ap�s cada n�mero, exceto o �ltimo
    addi $t9, $t9, -1                      # Decrementa o contador de elementos
    beqz $t9, end_conversion               # Se $t9 == 0, � o �ltimo n�mero; n�o adiciona v�rgula
    li $t4, ','                            # Caractere de v�rgula
    sb $t4, 0($t1)                         # Armazena a v�rgula na string de sa�da
    addi $t1, $t1, 1                       # Avan�a o ponteiro da string de sa�da

    j convert_to_string_loop               # Continua o loop para o pr�ximo n�mero

end_conversion:
    li $t4, 0                              # Terminador nulo para a string
    sb $t4, 0($t1)                         # Adiciona o terminador nulo � string de sa�da

    # Exibe a string de sa�da
    la $a0, output_str                     # Carrega o endere�o da string de sa�da
    li $v0, 4                              # Syscall para imprimir string
    syscall

    li $v0, 10                             # Syscall para terminar o programa
    syscall

# Fun��o: int_to_string
# Converte um inteiro em sua representa��o ASCII e armazena em $a1
# Entrada: $a0 = n�mero a ser convertido, $a1 = ponteiro de sa�da
# Sa�da: Retorna o ponteiro atualizado na sa�da ($v0)
int_to_string:
    li $t5, 0                              # Inicializa o contador de d�gitos
    li $t6, 0                              # Flag de negativo

    # Verifica se o n�mero � negativo
    bltz $a0, make_positive
    j extract_digits

make_positive:
    li $t6, 1                              # Marca como negativo
    sub $a0, $zero, $a0                    # Torna o n�mero positivo

extract_digits:
    li $t7, 10                             # Divisor constante
    addi $sp, $sp, -4                      # Reserva espa�o na pilha para cada d�gito

extract_loop:
    div $a0, $t7                           # Divide o n�mero por 10
    mfhi $t8                               # Resto da divis�o (d�gito menos significativo)
    addi $t8, $t8, 48                      # Converte o d�gito para ASCII
    sw $t8, 0($sp)                         # Armazena o d�gito na pilha
    addi $sp, $sp, -4                      # Move a pilha para pr�ximo d�gito
    mflo $a0                               # Atualiza $a0 com o quociente

    addi $t5, $t5, 1                       # Incrementa o contador de d�gitos
    bnez $a0, extract_loop                 # Continua at� que $a0 seja zero

    # Adiciona o sinal '-' se o n�mero for negativo
    beqz $t6, write_digits                 # Se $t6 == 0, o n�mero n�o � negativo
    li $t8, '-'                            # Caractere '-'
    sb $t8, 0($a1)                         # Armazena o '-' na string de sa�da
    addi $a1, $a1, 1                       # Avan�a o ponteiro da string de sa�da

write_digits:
    addi $sp, $sp, 4                       # Ajusta para o �ltimo d�gito armazenado
write_loop:
    lw $t8, 0($sp)                         # Recupera o d�gito da pilha
    sb $t8, 0($a1)                         # Escreve o d�gito na string de sa�da
    addi $a1, $a1, 1                       # Avan�a o ponteiro da string de sa�da
    addi $sp, $sp, 4                       # Avan�a na pilha

    addi $t5, $t5, -1                      # Decrementa o contador de d�gitos
    bgtz $t5, write_loop                   # Continua at� que todos os d�gitos sejam escritos

    move $v0, $a1                          # Retorna o ponteiro atualizado ($v0)
    jr $ra                                 # Retorna ao chamador