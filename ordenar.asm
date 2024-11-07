.data
string: .asciiz "245,34,-45,3,-674,0,235"  # String contendo números separados por vírgulas
.align 2                                   # Alinhamento de memória
numbers: .space 40                         # Espaço para armazenar até 10 números (4 bytes cada)
num_count: .word 0                         # Contador de números armazenados
output_str: .space 100                     # Espaço para a string de saída (inclui vírgulas e terminador nulo)

.text
main:
    # Conversão de string para inteiros e armazenamento no vetor
    la $t0, string                         # Carrega o endereço da string original
    la $t1, numbers                        # Endereço onde os números convertidos serão armazenados
    li $t7, 0                              # Flag de número negativo (0 = positivo, 1 = negativo)
    li $t2, 0                              # Inicializa o acumulador do número atual
    li $t8, 0                              # Contador de números convertidos

convert_loop:
    lb $t3, ($t0)                          # Carrega o próximo caractere da string
    beq $t3, $zero, store_last_number      # Se for o fim da string, armazena o último número

    li $t4, ','                            # Caractere de vírgula
    beq $t3, $t4, store_number             # Se for vírgula, armazena o número e continua

    li $t4, '-'                            # Caractere de menos
    beq $t3, $t4, set_negative             # Se for '-', define o número como negativo e continua

    # Converte o caractere ASCII para número
    sub $t3, $t3, 48                       # Subtrai 48 para obter o valor numérico
    mul $t2, $t2, 10                       # Multiplica o acumulador por 10 para deslocar um dígito
    add $t2, $t2, $t3                      # Adiciona o dígito atual ao número acumulado

    addi $t0, $t0, 1                       # Avança para o próximo caractere
    j convert_loop                         # Continua o loop

set_negative:
    li $t7, 1                              # Define a flag para indicar número negativo
    addi $t0, $t0, 1                       # Avança para o próximo caractere após o '-'
    j convert_loop                         # Continua o loop

store_number:
    # Se o número é negativo, inverte o sinal
    beq $t7, $zero, skip_negate
    sub $t2, $zero, $t2                    # Converte o número para negativo
    li $t7, 0                              # Reseta a flag de negativo

skip_negate:
    # Armazena o número atual no vetor de números
    sw $t2, 0($t1)                         # Armazena o número no vetor em $t1
    addi $t1, $t1, 4                       # Avança para o próximo espaço no vetor
    addi $t8, $t8, 1                       # Incrementa o contador de números
    li $t2, 0                              # Reseta o acumulador do número atual

    addi $t0, $t0, 1                       # Avança para o próximo caractere
    j convert_loop                         # Continua o loop

store_last_number:
    # Armazena o último número acumulado ao final da string
    beq $t2, $zero, sort_numbers           # Se o acumulador estiver vazio, não armazena

    # Se o número é negativo, inverte o sinal
    beq $t7, $zero, skip_last_negate
    sub $t2, $zero, $t2                    # Converte o número para negativo
    li $t7, 0                              # Reseta a flag de negativo

skip_last_negate:
    sw $t2, 0($t1)                         # Armazena o último número no vetor
    addi $t8, $t8, 1                       # Incrementa o contador de números

    sw $t8, num_count                      # Armazena o contador de números em num_count

# Ordenação dos números com Bubble Sort
sort_numbers:
    la $t1, numbers                        # Reinicia o ponteiro para o início do vetor
    lw $t9, num_count                      # Carrega o número total de elementos

outer_loop:
    addi $t9, $t9, -1                      # Ajusta o limite do loop externo
    li $t0, 0                              # Índice para o loop interno

inner_loop:
    lw $t2, 0($t1)                         # Carrega o número atual
    lw $t3, 4($t1)                         # Carrega o próximo número

    # Compara e troca se necessário
    ble $t2, $t3, skip_swap                # Se $t2 <= $t3, não troca
    sw $t3, 0($t1)                         # Coloca o menor número na posição atual
    sw $t2, 4($t1)                         # Coloca o maior número na próxima posição

skip_swap:
    addi $t1, $t1, 4                       # Avança para o próximo par
    addi $t0, $t0, 1                       # Incrementa o índice
    blt $t0, $t9, inner_loop               # Continua o loop interno

    la $t1, numbers                        # Reinicia o ponteiro para o início do vetor
    bgt $t9, 1, outer_loop                 # Continua o loop externo se necessário

# Conversão dos inteiros ordenados para strings e exibição
display_sorted_numbers:
    la $t0, numbers                        # Ponteiro para o início do vetor ordenado
    la $t1, output_str                     # Ponteiro para armazenar a string de saída
    lw $t9, num_count                      # Carrega o número total de elementos

convert_to_string_loop:
    lw $a0, 0($t0)                         # Carrega o próximo número do vetor
    addi $t0, $t0, 4                       # Avança para o próximo número no vetor
    move $a1, $t1                          # Passa o ponteiro de saída para $a1
    jal int_to_string                      # Chama a função para converter o número em string
    move $t1, $v0                          # Atualiza o ponteiro de saída para o final da string convertida

    # Adiciona uma vírgula após cada número, exceto o último
    addi $t9, $t9, -1                      # Decrementa o contador de elementos
    beqz $t9, end_conversion               # Se $t9 == 0, é o último número; não adiciona vírgula
    li $t4, ','                            # Caractere de vírgula
    sb $t4, 0($t1)                         # Armazena a vírgula na string de saída
    addi $t1, $t1, 1                       # Avança o ponteiro da string de saída

    j convert_to_string_loop               # Continua o loop para o próximo número

end_conversion:
    li $t4, 0                              # Terminador nulo para a string
    sb $t4, 0($t1)                         # Adiciona o terminador nulo à string de saída

    # Exibe a string de saída
    la $a0, output_str                     # Carrega o endereço da string de saída
    li $v0, 4                              # Syscall para imprimir string
    syscall

    li $v0, 10                             # Syscall para terminar o programa
    syscall

# Função: int_to_string
# Converte um inteiro em sua representação ASCII e armazena em $a1
# Entrada: $a0 = número a ser convertido, $a1 = ponteiro de saída
# Saída: Retorna o ponteiro atualizado na saída ($v0)
int_to_string:
    li $t5, 0                              # Inicializa o contador de dígitos
    li $t6, 0                              # Flag de negativo

    # Verifica se o número é negativo
    bltz $a0, make_positive
    j extract_digits

make_positive:
    li $t6, 1                              # Marca como negativo
    sub $a0, $zero, $a0                    # Torna o número positivo

extract_digits:
    li $t7, 10                             # Divisor constante
    addi $sp, $sp, -4                      # Reserva espaço na pilha para cada dígito

extract_loop:
    div $a0, $t7                           # Divide o número por 10
    mfhi $t8                               # Resto da divisão (dígito menos significativo)
    addi $t8, $t8, 48                      # Converte o dígito para ASCII
    sw $t8, 0($sp)                         # Armazena o dígito na pilha
    addi $sp, $sp, -4                      # Move a pilha para próximo dígito
    mflo $a0                               # Atualiza $a0 com o quociente

    addi $t5, $t5, 1                       # Incrementa o contador de dígitos
    bnez $a0, extract_loop                 # Continua até que $a0 seja zero

    # Adiciona o sinal '-' se o número for negativo
    beqz $t6, write_digits                 # Se $t6 == 0, o número não é negativo
    li $t8, '-'                            # Caractere '-'
    sb $t8, 0($a1)                         # Armazena o '-' na string de saída
    addi $a1, $a1, 1                       # Avança o ponteiro da string de saída

write_digits:
    addi $sp, $sp, 4                       # Ajusta para o último dígito armazenado
write_loop:
    lw $t8, 0($sp)                         # Recupera o dígito da pilha
    sb $t8, 0($a1)                         # Escreve o dígito na string de saída
    addi $a1, $a1, 1                       # Avança o ponteiro da string de saída
    addi $sp, $sp, 4                       # Avança na pilha

    addi $t5, $t5, -1                      # Decrementa o contador de dígitos
    bgtz $t5, write_loop                   # Continua até que todos os dígitos sejam escritos

    move $v0, $a1                          # Retorna o ponteiro atualizado ($v0)
    jr $ra                                 # Retorna ao chamador