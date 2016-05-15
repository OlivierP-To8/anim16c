/*******************************************************************************
 * Rapide programme pour transformer la palette d'un bmp 16 couleurs en data asm
 * Auteur : OlivierP
*******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

double gamma(unsigned char val)
{
	double V = val;
	V /= 255.0;

	// conversion to linear https://en.wikipedia.org/wiki/Rec._709
	if (V < 0.081)
	{
		V /= 4.5;
	}
	else
	{
		V = pow((V+0.099)/1.099, 1.0/0.45);
	}

	return V * 255.0;
}

const double P1 = 200.0;
const double P2 = 200.0;
double ybezier(double t)
{
	double y = 0.0; //(1.0-t)*(1.0-t)*(1.0-t)*0.0;
	y += 3.0*(1.0-t)*(1.0-t)*t*P1;
	y += 3.0*(1.0-t)*t*t*P2;
	y += t*t*t*255.0;
	return y;
}

unsigned char intensite(double val)
{
	unsigned char ret=0;
	for (int i=0; i<=15; i++)
	{
		double t = i;
		t/=15.0; // t entre 0 et 1
		if (ybezier(t)<=val)
			ret=i;
	}
	return ret;
}

int main(int argc, char **argv)
{
	if (argc < 3)
	{
		printf("\nusage : %s fichier.bmp nom\n", argv[0]);
	}
	else
	{
		FILE *f = fopen(argv[1], "rb");
		if (f != NULL)
		{
			fseek(f, 0x7a, SEEK_SET); // début palette
			printf("DEB%s\n", argv[2]);
			for (int p=0; p<16; p++)
			{
				unsigned char b = fgetc(f);
				unsigned char v = fgetc(f);
				unsigned char r = fgetc(f);
				unsigned char a = fgetc(f);
				double gb = gamma(b);
				double gv = gamma(v);
				double gr = gamma(r);
				printf("   FDB $%02x%02x * %02x %02x %02x\n", intensite(gb), intensite(gv)*16 + intensite(gr), r, v, b);
			}
			printf("FIN%s\n\n", argv[2]);
			fclose(f);
		}
		else
		{
			printf("impossible d'ouvrir %s\n", argv[1]);
		}
	}
	return 0;
}
