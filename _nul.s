.data

nul: .asciiz "Ton entier est nul!\n"

.text
.globl __start

__start:

li $t0 0

beq $t0 $0 Nul #si $t0 = $0 va à Nul
j Exit #saut vers la fin du processus

Nul:
la $a0 nul #adresse de la chaîne à afficher
li $v0 4 #appel système 4: afficher une chaîne de caractère
syscall

Exit: 
li $v0 10
syscall
