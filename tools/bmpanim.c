/*******************************************************************************
 * Rapide programme pour transformer les differences entre deux bmp 16 couleurs en data asm
 * Auteur : OlivierP
 * Attention à l'ordre des fichiers, il y a deux pages écrans !
 * il ne faut pas calculer les différences avec l'image précédente, mais avec 2 images précédentes
*******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

typedef unsigned char BYTE;
typedef unsigned short WORD;
typedef unsigned int DWORD;

typedef struct tagBITMAPFILEHEADER
{
  WORD  bfType;
  DWORD bfSize;
  WORD  bfReserved1;
  WORD  bfReserved2;
  DWORD bfOffBits;
} BITMAPFILEHEADER;

typedef struct tagBITMAPINFOHEADER
{
  DWORD biSize;
  int  biWidth;
  int  biHeight;
  WORD  biPlanes;
  WORD  biBitCount;
  DWORD biCompression;
  DWORD biSizeImage;
  int  biXPelsPerMeter;
  int  biYPelsPerMeter;
  DWORD biClrUsed;
  DWORD biClrImportant;
} BITMAPINFOHEADER;

typedef struct tagRGBQUAD
{
  BYTE rgbBlue;
  BYTE rgbGreen;
  BYTE rgbRed;
  BYTE rgbReserved;
} RGBQUAD;


int main(int argc, char **argv)
{
	int retval = 1;
	if (argc < 4)
		printf("usage : %s fichier1.bmp fichier2.bmp nom\n", argv[0]);
	else
	{
		FILE *f1 = fopen(argv[1], "rb");
		FILE *f2 = fopen(argv[2], "rb");
		if ((f1 != NULL) && (f2 != NULL))
		{
			BITMAPFILEHEADER bmfh1, bmfh2;
			size_t nbread1 = fread(&bmfh1, 1, 14, f1);
			size_t nbread2 = fread(&bmfh2, 1, 14, f2);
			if ((bmfh1.bfType == 0x4d42) && (bmfh2.bfType == 0x4d42))
			{
				BITMAPINFOHEADER Info1, Info2;
				nbread1 = fread(&Info1, 1, sizeof(BITMAPINFOHEADER), f1);
				nbread2 = fread(&Info2, 1, sizeof(BITMAPINFOHEADER), f2);
				if ((nbread1 == sizeof(BITMAPINFOHEADER)) && (nbread2 == sizeof(BITMAPINFOHEADER)))
				{
					int width = Info1.biWidth;
					int height = Info1.biHeight;
					//int pitch = (width%8) ? ((width>>3)+1)<<3 : width;

					if ((Info1.biWidth!=Info2.biWidth) || (Info1.biHeight!=Info2.biHeight))
					{
						printf("les deux fichiers ne sont pas de la même taille\n");
					}
					else if ((Info1.biBitCount!=4) || (Info2.biBitCount!=4))
					{
						printf("les deux fichiers doivent être en 16 couleurs (%d %d)\n", Info1.biBitCount, Info2.biBitCount);
					}
					else if ((Info1.biCompression!=0) || (Info2.biCompression!=0))
					{
						printf("les deux fichiers doivent être non compréssés (%d %d)\n", Info1.biCompression, Info2.biCompression);
					}
					else
					{
						retval = 0;
						printf("%s\n", argv[3]);

						unsigned int nbcolors1 = (int)(pow(2.0f, (float)(Info1.biBitCount)));
						if (!Info1.biClrUsed)
							Info1.biClrUsed = nbcolors1;
						unsigned int nbcolors2 = (int)(pow(2.0f, (float)(Info2.biBitCount)));
						if (!Info2.biClrUsed)
							Info2.biClrUsed = nbcolors2;

						if (Info1.biClrUsed!=Info2.biClrUsed)
						{
							printf("les deux fichiers doivent avoir le même nombre de couleurs (%d %d)\n", Info1.biClrUsed, Info2.biClrUsed);
							retval = 1;
						}
						RGBQUAD palette1[16];
						nbread1 = fread(&palette1, sizeof(RGBQUAD), Info1.biClrUsed, f1);
						RGBQUAD palette2[16];
						nbread1 = fread(&palette2, sizeof(RGBQUAD), Info2.biClrUsed, f2);
						for (unsigned int p=0; p<Info1.biClrUsed; p++)
						{
							if ((palette1[p].rgbBlue != palette2[p].rgbBlue) ||
								(palette1[p].rgbGreen != palette2[p].rgbGreen) ||
								(palette1[p].rgbRed != palette2[p].rgbRed))
							{
								printf("les deux fichiers doivent avoir la même palette\n");
								retval = 1;
							}
						}
						//fseek(f1, 0, SEEK_END);
						//int pos1 = ftell(f1);
						fseek(f2, 0, SEEK_END);
						int pos2 = ftell(f2);

						unsigned short addrvid = 0;
						unsigned short *ligne1 = malloc(width/2);
						unsigned short *ligne2 = malloc(width/2);
						for (int i=height; i>0; i--)
						{
							pos2 -= width/2;
							fseek(f1, pos2, SEEK_SET);
							fseek(f2, pos2, SEEK_SET);
							fread(ligne1, 2, width/4, f1);
							fread(ligne2, 2, width/4, f2);

							int debut=0, fin=0;
							for (int j=0; j<width/4; j++)
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
				}
			}
			fclose(f1);
			fclose(f2);
		}
		else printf("impossible d'ouvrir %s et/ou %s\n", argv[1], argv[2]);
	}
	return retval;
}
