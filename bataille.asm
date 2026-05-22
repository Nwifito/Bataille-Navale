.data 
    grille:     .space 100                      # Réserve 100 octets en mémoire pour la grille (10x10 cases)
    
# ===== Section code =====  
.text

    li      $t9, 0                              # Initialise le registre $t9 à 0 (compteur global pour le nombre de coups réussis)

# ----- Main ----- 
main:
    jal     initPartie                          # Saute à la fonction initPartie et sauvegarde l'adresse de retour
    jal     displayGrille                       # Saute à la fonction displayGrille pour afficher l'état initial
    
    boucle_main:                                # Étiquette de début de la boucle principale du jeu
        beq     $t9, 17, fin_boucle_main        # Si le compteur de touches ($t9) vaut 17 (tous bateaux coulés), aller à fin_boucle_main
        jal     simulationJeu                   # Sinon, saute à simulationJeu pour jouer un coup
        j       boucle_main                     # Recommence la boucle (tour suivant)
        
    fin_boucle_main:                            # Étiquette de fin de partie
        j       exit                            # Saute à l'étiquette exit pour terminer le programme

# ==============================================================================
# FONCTIONS
# ==============================================================================

# ------------------------------------------------------------------------------
# Fonction : initPartie
# ------------------------------------------------------------------------------
initPartie:
    add     $sp, $sp, -4                        # Décrémente le pointeur de pile de 4 octets (allocation)
    sw      $ra, 0($sp)                         # Sauvegarde l'adresse de retour ($ra) dans la pile

    jal     initGrille                          # Appelle la fonction pour remplir la grille de points '.'
    
    li      $a0, 5                              # Charge 5 dans $a0 (Taille du Porte-Avion)
    li      $a1, 65                             # Charge 65 ('A') dans $a1 (Caractère ASCII)
    jal     setShip                             # Appelle la fonction pour placer le bateau 'A'
    
    li      $a0, 4                              # Charge 4 dans $a0 (Taille du Cuirassé)
    li      $a1, 66                             # Charge 66 ('B') dans $a1
    jal     setShip                             # Appelle la fonction pour placer le bateau 'B'
    
    li      $a0, 3                              # Charge 3 dans $a0 (Taille du Croiseur)
    li      $a1, 67                             # Charge 67 ('C') dans $a1
    jal     setShip                             # Appelle la fonction pour placer le bateau 'C'
    
    li      $a0, 3                              # Charge 3 dans $a0 (Taille du Sous-marin)
    li      $a1, 83                             # Charge 83 ('S') dans $a1
    jal     setShip                             # Appelle la fonction pour placer le bateau 'S'
    
    li      $a0, 2                              # Charge 2 dans $a0 (Taille du Destroyer)
    li      $a1, 68                             # Charge 68 ('D') dans $a1
    jal     setShip                             # Appelle la fonction pour placer le bateau 'D'

    lw      $ra, 0($sp)                         # Récupère l'adresse de retour initiale depuis la pile
    add     $sp, $sp, 4                         # Incrémente le pointeur de pile de 4 (libération)
    jr      $ra                                 # Retourne à l'appelant (main)

# ------------------------------------------------------------------------------
# Fonction : initGrille
# ------------------------------------------------------------------------------
initGrille:
    la      $t0, grille                         # Charge l'adresse mémoire du début du tableau 'grille' dans $t0
    li      $t1, 0                              # Initialise le compteur $t1 à 0
    li      $t3, 46                             # Charge le code ASCII 46 ('.') dans $t3
    
    boucle_initGrille:                          # Début de la boucle de remplissage
        bge     $t1, 100, end_initGrille        # Si $t1 >= 100, on sort de la boucle (fin du tableau)
        add     $t2, $t0, $t1                   # $t2 = Adresse de base ($t0) + index ($t1)
        sb      $t3, 0($t2)                     # Stocke l'octet '.' ($t3) à l'adresse $t2
        addi    $t1, $t1, 1                     # Incrémente le compteur $t1 de 1
        j       boucle_initGrille               # Recommence la boucle
        
    end_initGrille:                             # Étiquette de fin de la fonction
        jr      $ra                             # Retourne à l'appelant

# ------------------------------------------------------------------------------
# Fonction : displayGrille
# Objectif : Affiche la grille complète en utilisant displayLettres et addLineCount.
# ------------------------------------------------------------------------------
displayGrille:
    add     $sp, $sp, -4                        # Allocation pile
    sw      $ra, 0($sp)                         # Sauvegarde adresse retour
    
    jal     displayLettres                      # Affiche les lettres colonnes (A-J) au-dessus
    jal     addNewLine                          # Saut de ligne
    
    la      $t0, grille                         # $t0 pointe sur le début de la grille
    li      $t1, 0                              # Initialise l'index de ligne ($t1) à 0
    
    loop_lignes_visuel:                         # Boucle pour chaque ligne (0 à 9)
        bge     $t1, 10, fin_display_grille     # Arrêt si on dépasse la dernière ligne
        
        move    $a1, $t1                        
        jal     addLineCount                    # Affiche le numéro de la ligne courante à gauche
        
        li      $t2, 0                          # Initialise l'index de colonne ($t2) à 0
        
        # Gestion de l'alignement pour les chiffres < 10 (ajout d'un espace)
        beq     $t1, 9, loop_cols_visuel        
        li      $a0, 32                         
        li      $v0, 11               
        syscall                                 
        
        loop_cols_visuel:                       # Boucle pour chaque colonne (0 à 9)
            bge     $t2, 10, next_ligne_visuel  # Fin de la ligne, on passe à la suivante
            
            mul     $t3, $t1, 10                # Offset Ligne = Ligne * 10
            add     $t3, $t3, $t2               # Offset Total = Offset Ligne + Colonne
            add     $t3, $t3, $t0               # Adresse mémoire finale
            
            lb      $a0, 0($t3)                 # Lecture de la case
            li      $v0, 11                     
            syscall                             # Affichage du caractère
            
            li      $a0, 32                     
            li      $v0, 11    
            syscall                             # Espace pour aérer l'affichage entre les colonnes
            
            addi    $t2, $t2, 1                 # Colonne suivante
            j       loop_cols_visuel            
            
        next_ligne_visuel:                      
            jal     addNewLine                  # Saut de ligne en fin de rangée
            addi    $t1, $t1, 1                 # Ligne suivante
            j       loop_lignes_visuel      
            
    fin_display_grille:                         
        jal     addNewLine                      # Saut de ligne final pour propreté
        lw      $ra, 0($sp)                     
        add     $sp, $sp, 4                     
        jr      $ra                             

# ------------------------------------------------------------------------------
# Fonction : displayLettres
# Objectif : Affiche les lettres au-dessus de la grille (A à J).
# ------------------------------------------------------------------------------
displayLettres:
    # Marge initiale pour s'aligner avec les numéros de lignes
    li      $a0, 32                             
    li      $v0, 11                             
    syscall           
    syscall                                     
    syscall                       
    
    li      $t0, 65                             # Commence à ASCII 65 ('A')
    
    boucle_alpha:                               # Boucle sur les lettres de l'alphabet
        beq     $t0, 75, fin_boucle_alpha       # Stop à 'K' (75)
        
        move    $a0, $t0                        
        li      $v0, 11         
        syscall                                 # Affiche la lettre courante
        
        li      $a0, 32               
        li      $v0, 11                         
        syscall                                 # Affiche l'espace séparateur
        
        addi    $t0, $t0, 1                     # Incrémente code ASCII
        j       boucle_alpha                    
        
    fin_boucle_alpha:  
        jr      $ra                             

# ------------------------------------------------------------------------------
# Fonction : addNewLine
# ------------------------------------------------------------------------------
addNewLine:
    li      $v0, 11                             # Syscall print_char
    li      $a0, 10                             # Code ASCII 10 ('\n')
    syscall                                     # Exécute l'affichage
    jr      $ra                                 # Retourne

# ------------------------------------------------------------------------------
# Fonction : addLineCount
# Objectif : Affiche le numéro de la ligne (converti de 0-9 à 1-10).
# ------------------------------------------------------------------------------
addLineCount:
    move    $a0, $a1                            # Récupère l'index de ligne
    addi    $a0, $a0, 1                         # Ajoute 1 pour l'affichage humain (1 au lieu de 0)
    li      $v0, 1                              # Syscall print_int
    syscall                                     

    li      $a0, 32               
    li      $v0, 11                             
    syscall                                     # Espace après le numéro
    
    jr      $ra                                 

# ------------------------------------------------------------------------------
# Fonction : getAleatoire
# ------------------------------------------------------------------------------
getAleatoire:
    li      $v0, 42                             # Syscall code 42 (Random int range)
    syscall                                     # Génère le nombre dans $a0 (utilise $a1 comme borne)
    jr      $ra                                 # Retourne

# ------------------------------------------------------------------------------
# Fonction : setShip
# ------------------------------------------------------------------------------
setShip:
    addi    $sp, $sp, -4                        # Allocation pile
    sw      $ra, 0($sp)                         # Sauvegarde adresse retour

    move    $s0, $a0                            # Sauvegarde la taille dans $s0 (registre préservé)
    move    $s4, $a1                            # Sauvegarde le caractère dans $s4
    
    try_setShip:                              
        # Choix de l'axe (0 = Horizontal, 1 = Vertical)
        li      $a1, 2                          # Borne sup pour random (0 ou 1)
        jal     getAleatoire                    # Génère nombre
        move    $s1, $a0                        # $s1 contient l'orientation
        beq     $s1, 1, go_verticale            # Si 1, va placer verticalement

        # Cas Horizontal
        jal     placeHorizontale                # Tente placement horizontal
        j       end_setShip                     # Si retour ici, fini, on saute à la fin

    go_verticale:
        jal     placeVerticale                  # Tente placement vertical

    end_setShip:                                # Fin du placement
        lw      $ra, 0($sp)                     # Restaure adresse retour
        addi    $sp, $sp, 4                     # Libère pile
        jr      $ra                             # Retourne

# ------------------------------------------------------------------------------
# Fonction : placeHorizontale
# Objectif : Choix coords aléatoires -> Vérif -> Placement physique horizontal.
# ------------------------------------------------------------------------------
placeHorizontale:
    addi    $sp, $sp, -4                        
    sw      $ra, 0($sp)                         

    nouvel_essai_h:                             # Point de retour pour retenter le tirage
        
        # Tirage aléatoire de la Ligne ($s2)
        li      $a1, 10                         
        jal     getAleatoire                    
        move    $s2, $a0                        

        # Tirage aléatoire de la Colonne ($s3)
        li      $a1, 10                         
        jal     getAleatoire                    
        move    $s3, $a0                        

        # Appel de la vérification
        jal     verifPlaceHorizontale           
        bnez    $v0, nouvel_essai_h             # Si verif renvoie erreur (non nul), on recommence

    # Placement physique sur la grille (Si on est ici, c'est valide)
    la      $t2, grille                         
    mul     $t3, $s2, 10                        # Offset Y
    add     $t3, $t3, $s3                       # Offset X
    add     $t2, $t2, $t3                       # $t2 = Adresse de la première case

    li      $t1, 0                              # Compteur pour la longueur du bateau

    ecriture_memoire_h:                          
        beq     $t1, $s0, fin_ecriture_h        # Stop quand on a écrit 'taille' caractères
        
        sb      $s4, 0($t2)                     # Remplace le point par la lettre du navire
        
        addi    $t2, $t2, 1                     # Avance d'une case (horizontalement)
        addi    $t1, $t1, 1                     
        j       ecriture_memoire_h              

    fin_ecriture_h:                          
        lw      $ra, 0($sp)                     
        addi    $sp, $sp, 4                     
        jr      $ra   

# ------------------------------------------------------------------------------
# Fonction : verifPlaceHorizontale
# Objectif : Vérifie si cases vides et pas de dépassement.
# Retour : $v0 (0 = OK, 1 = Problème).
# ------------------------------------------------------------------------------
verifPlaceHorizontale:
    # 1. Vérifie si le bateau dépasse la bordure droite
    add     $t0, $s3, $s0                       # Colonne + Taille
    li      $t1, 10                             
    bgt     $t0, $t1, echec_verif_h             # Si > 10, impossible

    # 2. Vérifie si toutes les cases sont libres ('.')
    la      $t2, grille                         
    mul     $t3, $s2, 10                       
    add     $t3, $t3, $s3                       
    add     $t2, $t2, $t3                       # Pointeur case départ

    li      $t3, 46                             # ASCII pour '.'
    li      $t4, 0                              # Compteur cases vérifiées

    check_vide_h:                               
        beq     $t4, $s0, succes_verif_h        # Tout est bon si on atteint la fin
        lb      $t0, 0($t2)                     
        bne     $t0, $t3, echec_verif_h         # Si case occupée, erreur
        addi    $t2, $t2, 1                     # Case suivante
        addi    $t4, $t4, 1                     
        j       check_vide_h                        

    echec_verif_h: 
        li      $v0, 1                          # Code erreur
        jr      $ra           

    succes_verif_h:                                
        li      $v0, 0                          # Code OK
        jr      $ra                             

# ------------------------------------------------------------------------------
# Fonction : placeVerticale
# Objectif : Choix coords aléatoires -> Vérif -> Placement physique vertical.
# ------------------------------------------------------------------------------
placeVerticale:
    sub     $sp, $sp, 4                         
    sw      $ra, 0($sp)                         

    nouvel_essai_v:                             # Recommencer le tirage
        
        # Tirage Ligne
        li      $a1, 10
        jal     getAleatoire
        move    $s2, $a0

        # Tirage Colonne
        li      $a1, 10
        jal     getAleatoire
        move    $s3, $a0

        # Vérification
        jal     verifPlaceVerticale             
        bnez    $v0, nouvel_essai_v             # Erreur -> on recommence

    # Placement physique
    la      $t2, grille                         
    mul     $t3, $s2, 10                        
    add     $t3, $t3, $s3                       
    add     $t2, $t2, $t3                       

    li      $t1, 0                              

    ecriture_memoire_v:               
        beq     $t1, $s0, fin_ecriture_v        
        
        sb      $s4, 0($t2)                     # Ecrit lettre
        
        addi    $t2, $t2, 10                    # Avance de 10 (Ligne suivante)
        addi    $t1, $t1, 1                     
        j       ecriture_memoire_v           

    fin_ecriture_v:                                
        lw      $ra, 0($sp)                     
        add     $sp, $sp, 4    
        jr      $ra                             

# ------------------------------------------------------------------------------
# Fonction : verifPlaceVerticale
# Objectif : Vérifie bordures et cases vides pour placement vertical.
# ------------------------------------------------------------------------------
verifPlaceVerticale:
    # 1. Vérifie bordure basse
    add     $t0, $s2, $s0                       # Ligne départ + Taille
    li      $t1, 10                             
    bgt     $t0, $t1, echec_verif_v             # Dépassement

    # 2. Vérifie contenu cases
    la      $t2, grille
    mul     $t3, $s2, 10
    add     $t3, $t3, $s3
    add     $t2, $t2, $t3

    li      $t3, 46                             # '.'
    li      $t4, 0                              

    check_vide_v:                                   
        beq     $t4, $s0, succes_verif_v      
        lb      $t0, 0($t2)                     
        bne     $t0, $t3, echec_verif_v         
        addi    $t2, $t2, 10                    # Case en dessous (+10)
        addi    $t4, $t4, 1                     
        j       check_vide_v                        

    echec_verif_v:       
        li      $v0, 1                          
        jr      $ra

    succes_verif_v:             
        li      $v0, 0                          
        jr      $ra

# ------------------------------------------------------------------------------
# Fonction : simulationJeu
# Objectif : Simule un tour. 
# Gère les compteurs 'nb_coups' (total) et 'nb_coups_but' ($t9).
# Lance la boucle de chasse (tirage + traque).
# ------------------------------------------------------------------------------
simulationJeu:
    addi    $sp, $sp, -4                        
    sw      $ra, 0($sp)                         

    # Note: On considère $t9 comme 'nb_coups_but'.
    # On incrémente ici un registre libre (ex: $k0) pour symboliser 'nb_coups' total
    addi    $k0, $k0, 1                         # Compteur total de coups joués

    retry_simu:                                 # Boucle de choix des coordonnées
        
        # Choix Ligne ($s2)
        li      $a1, 10
        jal     getAleatoire
        move    $s2, $a0

        # Choix Colonne ($s3)
        li      $a1, 10
        jal     getAleatoire
        move    $s3, $a0        
        
        # Appel de l'algo de traque
        jal     traque                          
        
        # Si traque retourne 0, la case était déjà jouée, on doit rejouer
        beqz    $v0, retry_simu                 
        
    lw      $ra, 0($sp)                      
    addi    $sp, $sp, 4                         
    jr      $ra                                 

# ------------------------------------------------------------------------------
# Fonction : traque
# Objectif : Algorithme récursif (Flood Fill) décrit en 2.3.1.
# Si navire : marque 'X', incrémente score, propage aux voisins.
# Si eau : marque '~'.
# ------------------------------------------------------------------------------
traque:
    # Sauvegarde contextuelle
    addi    $sp, $sp, -12                       
    sw      $ra, 0($sp)                         
    sw      $s2, 4($sp)                         # Ligne courante
    sw      $s3, 8($sp)                         # Colonne courante
    
    beq     $t9, 17, fin_traque_recursion       # Sécurité victoire

    # Calcul adresse mémoire de la cible
    la      $t2, grille                         
    mul     $t3, $s2, 10                        
    add     $t3, $t3, $s3          
    add     $t2, $t2, $t3                       

    # Lecture du contenu
    lb      $t7, 0($t2)                         
    
    # 1. Vérif si déjà joué
    li      $t8, 126                            # '~'
    beq     $t7, $t8, coup_invalide_deja_joue   
    li      $t8, 88                             # 'X'
    beq     $t7, $t8, coup_invalide_deja_joue   

    # 2. Vérif si Eau
    li      $t8, 46                             # '.'
    beq     $t7, $t8, plouf_dans_eau            

    # 3. Cas TOUCHÉ (Navire)
    li      $t5, 88                             # 'X'
    sb      $t5, 0($t2)                         # Marque la touche
    addi    $t9, $t9, 1                         # Incrémente 'nb_coups_but'

    jal     displayGrille                       # Mise à jour visuelle
    
    # --- Propagation Récursive (Haut, Gauche, Bas, Droite) ---
    
    # HAUT
    blt     $s2, 1, pas_de_haut                 # Bordure haute atteinte ?
        addi    $s2, $s2, -1                    
        jal     traque                          
        addi    $s2, $s2, 1                     # Retour position
    pas_de_haut:

    # GAUCHE
    blt     $s3, 1, pas_de_gauche               # Bordure gauche atteinte ?
        addi    $s3, $s3, -1                    
        jal     traque                     
        addi    $s3, $s3, 1                     # Retour position
    pas_de_gauche:

    # BAS
    bge     $s2, 9, pas_de_bas                  # Bordure basse atteinte ?
        addi    $s2, $s2, 1                     
        jal     traque                          
        addi    $s2, $s2, -1                    # Retour position
    pas_de_bas:

    # DROITE
    bge     $s3, 9, pas_de_droite               # Bordure droite atteinte ?
        addi    $s3, $s3, 1                     
        jal     traque                          
        addi    $s3, $s3, -1                    # Retour position
    pas_de_droite:

    li      $v0, 1                              # Succès
    j       fin_traque_recursion                

plouf_dans_eau:
    li      $t5, 126                            # '~'
    sb      $t5, 0($t2)                         # Marque le plouf
    jal     displayGrille                       
    
    li      $v0, 1                              # Succès (coup légal)
    j       fin_traque_recursion                

coup_invalide_deja_joue:
    li      $v0, 0                              # Echec (doit rejouer)

fin_traque_recursion:
    lw      $ra, 0($sp)                         
    lw      $s2, 4($sp)                         
    lw      $s3, 8($sp)                         
    addi    $sp, $sp, 12                        
    jr      $ra              

exit: 
    li $v0, 10                                  # Charge code syscall 10 (Exit)
    syscall                                     # Fin