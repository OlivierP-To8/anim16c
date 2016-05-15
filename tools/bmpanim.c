/*******************************************************************************
 * Rapide programme pour transformer les differences entre deux bmp 16 couleurs en data asm
 * Auteur : OlivierP
 * Attention à l'ordre des fichiers, il y a deux pages écrans !
 * il ne faut pas calculer les différences avec l'image précédente, mais avec 2 images précédentes
*******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
	if (argc < 4)
		printf("usage : %s fichier1.bmp fichier2.bmp nom\n", argv[0]);
	else
	{
		FILE *f1 = fopen(argv[1], "rb");
		FILE *f2 = fopen(argv[2], "rb");
		if ((f1 != NULL) && (f2 != NULL))
		{
			printf("%s\n", argv[3]);

			fseek(f1, 18, SEEK_SET);
			unsigned char w1 = fgetc(f1);
			fseek(f2, 18, SEEK_SET);
			unsigned char w2 = fgetc(f2);

			fseek(f1, 22, SEEK_SET);
			unsigned char h1 = fgetc(f1);
			fseek(f2, 22, SEEK_SET);
			unsigned char h2 = fgetc(f2);

			int pitch1 = (w1%8) ? ((w1>>3)+1)<<3 : w1;
			//int pitch2 = (w2%8) ? ((w2>>3)+1)<<3 : w2;

			fseek(f1, 0, SEEK_END);
			int pos1 = ftell(f1);
			//fseek(f2, 0, SEEK_END);
			//int pos2 = ftell(f2);

			if ((w1!=w2) || (h1!=h2))
			{
				printf("les deux fichiers ne sont pas de la même taille\n");
			}
			else
			{
				unsigned short addrvid = 0;
				unsigned short *ligne1 = malloc(w1/2);
				unsigned short *ligne2 = malloc(w1/2);
				for (int i=h1; i>0; i--)
				{
					pos1 -= pitch1/2;
					fseek(f1, pos1, SEEK_SET);
					fseek(f2, pos1, SEEK_SET);
					fread(ligne1, 2, w1/4, f1);
					fread(ligne2, 2, w1/4, f2);

					int debut=0, fin=0;
					for (int j=0; j<w1/4; j++)
					{
						if (ligne1[j]!=ligne2[j])
						{
							if (debut==0) // 1ere difference
							{
								debut=j;
							}
							fin=j;
						}
					}
					if (fin!=0)
					{
						printf("   FDB $%04x\n", addrvid+debut); // adresse video de début
						printf("   FDB $%04x\n", addrvid+fin+1); // adresse video de fin
						for (int j=debut; j<=fin; j++)
						{
							printf("   FDB $%04x   * $%04x sur bmp precedent\n", ligne2[j], ligne1[j]);
						}
						printf("\n");
					}
					addrvid+=80;
				}
				free(ligne1);
				free(ligne2);
			}
			fclose(f1);
			fclose(f2);
		}
		else printf("impossible d'ouvrir %s et/ou %s\n", argv[1], argv[2]);
	}
	return 0;
}
