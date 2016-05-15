********************************************************************************
*                               anim16c pour TO8                               *
********************************************************************************
* Auteur  : OlivierP (sauf si indication contraire)                            *
* Date    : mai 2016                                                           *
* Licence : GNU GPLv3 (http://www.gnu.org/copyleft/gpl.html)                   *
********************************************************************************

   ORCC #80        * ne pas interrompre

********************************************************************************
* Definition de la palette de couleurs
* 
* Provenance de ce bout de code : manuel technique des TO8, TO9, TO9+ page 70
* modifié par OlivierP pour faire les 16 valeurs
********************************************************************************
   CLRA
PALETTE_FOND
   PSHS A
   ASLA
   STA $E7DB
   LDD #$0000      * on force toutes les couleurs durant l'initialisation
   STB $E7DA
   STA $E7DA
   PULS A
   INCA
   CMPA #$F
   BNE PALETTE_FOND


********************************************************************************
* Passage en mode 160x200x16c
* 
* Provenance de ce bout de code :  manuel technique des TO8, TO9, TO9+ page 61
********************************************************************************
   LDA #$7B
   STA $E7DC


********************************************************************************
* Initialisation de la routine de commutation de page video
* 
* Provenance de ce bout de code :  http://pulsdemos.com/vector02.html
********************************************************************************
   LDB $6081
   ORB #$10
   STB $6081
   STB $E7E7


********************************************************************************
* Effacement ecran (les deux pages)
********************************************************************************
   JSR SCRC
   JSR EFF
   JSR SCRC
   JSR EFF


********************************************************************************
* Definition de la palette de couleurs
* 
* Provenance de ce bout de code : manuel technique des TO8, TO9, TO9+ page 70
* amélioré par OlivierP pour gérer un tableau de valeurs
********************************************************************************
   LDY #DEBPALET
   CLRA
PALETTE
   PSHS A
   ASLA
   STA $E7DB
   LDD ,Y++
   STB $E7DA
   STA $E7DA
   PULS A
   INCA
   CMPY #FINPALET
   BNE PALETTE


********************************************************************************
* Boucle principale
********************************************************************************

   LDA #BANKMIN    * première bank
   STA $E7E5       * commute la bank

   LDX #DEBFRAME   * X pointe vers l'adresse des données

BOUCLE_PRINC
   LDD ,X++        * D contient l'adresse de debut des données
   LDY ,X          * Y contient l'adresse de debut des données suivantes
   CMPY #$A000
   BNE FRAME_ANIM
   LDA BANKNUM     * lit la bank actuelle
   INCA            * passage à la bank suivante
   CMPA #BANKMAX
   BLS FRAME_BANK
   LDA #BANKMIN+1  * retour à la deuxième bank/troisième frame (sans les deux images de fond)
FRAME_BANK
   STA BANKNUM     * mémorise la nouvelle bank
   STA $E7E5       * commute la bank
   LDD ,X++        * D contient l'adresse de debut des données

FRAME_ANIM
   TFR D,Y         * Y contient l'adresse de debut des données
   PSHS X          * on sauve le pointeur vers l'adresse des données suivantes
   LDD ,X++        * D contient l'adresse de fin des données
   STA DESSIN_ADRFINDES+1
   STB DESSIN_ADRFINDES+2
   TFR Y,X         * X contient l'adresse de debut des données

FRAME_LIGNE
   LDY ,X++        * Y contient l'adresse video de début de ligne
   LDD ,X++        * D (A et B) contient l'adresse video de fin de ligne
   STA DESSIN_ADRFINLIG+2
   STB DESSIN_ADRFINLIG+3

DESSIN
   LDD ,X++        * D (A et B) contient le point bitmap (X pointe vers les donnees graphiques)
   STB $0000,Y     * écrit les 2 pixels contenus dans B en RAMA (4 bits par pixel)
   STB $0028,Y     * écrit les 2 pixels contenus dans B sur la ligne suivante en RAMA afin d'avoir des pixels carrés
   STA $2000,Y     * écrit les 2 pixels contenus dans A en RAMB (4 bits par pixel)
   STA $2028,Y     * écrit les 2 pixels contenus dans A sur la ligne suivante en RAMB afin d'avoir des pixels carrés
   LEAY 1,Y
DESSIN_ADRFINLIG
   CMPY #$0000     * cette valeur est initialisée avant DESSIN
   BLT DESSIN      * aller à DESSIN si pas fin de ligne
DESSIN_ADRFINDES
   CMPX #$0000     * cette valeur est initialisée avant FRAME_LIGNE
   BLT FRAME_LIGNE * boucler si c'est n'est pas la derniere ligne

   JSR SCRC        * changement de page écran

   PULS X          * X pointe vers l'adresse des données de la frame suivante
   CMPX #FINFRAME-2
   BLT BOUCLE_PRINC
   LDX #DEBFRAME+4 * on boucle sur la troisième frame (sans les deux images de fond)
   BRA BOUCLE_PRINC


********************************************************************************
* Effacement de l'écran
********************************************************************************
EFF
   LDA #BACKCOL  * couleur fond
   LDY #$0000
EFF_RAM
   STA ,Y+
   CMPY #$3FFF
   BNE EFF_RAM
   RTS


********************************************************************************
* Changement de page écran
* 
* Provenance de ce bout de code :  http://pulsdemos.com/vector02.html
********************************************************************************
SCRC
   LDB SCRC0+1
   ANDB #$80          * BANK1 utilisée ou pas pour l'affichage / fond couleur 0
   ORB #$0A           * contour écran = couleur A
   STB $E7DD
   COM SCRC0+1
SCRC0
   LDB #$00
   ANDB #$02          * page RAM no0 ou no2 utilisée dans l'espace cartouche
   ORB #$60           * espace cartouche recouvert par RAM / écriture autorisée
   STB $E7E6
   RTS

* Comment cette routine fonctionne-t-elle ?
* Premierement, il convient de noter que SCRC0+1 est l'adresse en mémoire de la valeur du LDB #$00.
* Plutot que d'utiliser une variable et de charger et décharger (par les LDB / STB), nous modifions directement le programme lui meme.
* Cette technique va nous permettre de sauver du temps lors de l'exécution du programme.
* A la première exécution de cette routine, nous allons charger dans B la valeur qui se trouve dans SCRC0 LDB #$00, soit $00.
* Nous appliquons un ET logique qui ne changera pas le résultat, la valeur stockée dans $E7DD sera $00.
* Nous complémentons la valeur du LDB #$00.
* Le programme va donc s'auto-modifier et le LDB #$00 va se transformer en LDB #$FF (Une complémentation met les bits 0 à 1 et les bits 1 à 0)
* Le programme continue son exécution et trouve un LDB #$FF, et charge donc $FF dans B naturellement.
* Le reste sont des opérations logique qui produisent au final la valeur $62.
* A la deuxième exécution de cette routine, notre ligne était restée à l'état LDB #$FF.
* Un COM SCRC0+1 complémentera donc le $FF ce qui modifera le programme et changera cette ligne en LDB #$00.
* La valeur qui résultera des opérations qui suivent sera $60.
* Nous avons donc une routine qui permute entre les valeurs $00/$80, et $60/$62 à chaque fois qu'elle est exécutée.  	  	  	 

* http://www.logicielsmoto.com/phpBB/viewtopic.php?p=787#787
* la memoire video se trouve a $0000 et $2000 pour les 2 RAMs plutot qu'en $4000 avec commutation pour les 2 RAMs.
* Ca simplifie enormement la programmation d'avoir les 16 kilo lineaires et a la meme adresse quelques soit l'ecran affiche,
* plutot que d'avoir a travailler soit en $4000 (en prenant soin de commuter RAMA/RAMB), soit en $a000 et $c000 suivant le cas.
* Ce que l'on fait est "simplement" de deplacer la "fenetre visible" sur l'espace normal ou la banque.
* Mais d'un point de vue programmation, c'est visible en $0000 quelque soit la page selectionne. 

* http://www.logicielsmoto.com/phpBB/viewtopic.php?p=796#796
* En fait, on n'utilise pas proprement dit la zone $0000-$3FFF, mais on cree une fenetre au adresses $0000-$3FFF
* On peut alors deplacer cette fenetre sur la zone memoire video ($4000) ou BANK 1 ($A000).
* Cela permet de pouvoir gerer 2 pages videos, toujours a la meme adresse.
* La routine de commutation doit etre appele a chaque fois que tu changes d'image (frame).
* Cette routine pointe l'affichage video dans la bonne banque ($4000 ou $A000) et
* commute l'ecriture video dans l'autre banque (celle qui n'est pas affichee).
* Cela permet donc d'afficher un ecran, et d'ecrire dans un ecran (invisible).
* Lorsque l'affichage est fini, on appel la routine, et on commute les 2.
* Celle qui etait ecrite devient visible, et celle qui etait visible devient invisible et disponible a l'ecriture. 

* http://pulsdemos.com/vector03.html
* notre écran sera positionnné en mémoire à partir de l'adresse &H0000.
* La RAMA se trouvera de &H0000 a &H1FFF et la RAMB se trouvera de &H2000 a &H3FFF.

BANKNUM FCB BANKMIN

