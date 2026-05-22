.data

hello: .asciiz "La barbe de Z, c'est un vrai myst�re !\n"

.text
.globl __start

__start:
la $a0 hello #adresse de la chaîne à afficher
li $v0 4 #appel système 4: afficher une chaîne de caractère
syscall

j Exit #saut vers la fin du processus

Exit: 
li $v0 10
syscall
