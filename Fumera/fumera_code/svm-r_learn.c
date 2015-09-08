/* main */

#include<stdio.h>
#include<stdlib.h>
#include<time.h>	/* serve per la generazione di un numero casuale */
#include<float.h>
#include<limits.h>	/* serve per definire la cost. infinity */
#include <math.h>
#include "compute_theta2.c"

double scalar_product(const double *v1, const double *v2);
void update_w(int i, int j, double alphaTemp, double c);
double update_b(int i,int j);
double right_extreme(int i, int j, double alphaStar, double c, double coefA, double coefB);
double golden_section(int i, int j, double sx, double dx, double coefA, double coefB, double c, double precision);
int takestep(int i,int j,double coefA,double coefB,double c);
int examine_example(int i);
void update_csi(void);
void initialize(void);
long get_runtime();

void memory_allocation(void);
void memory_deallocation(void);

const double infinity=DBL_MAX;
const double zero= 100*DBL_EPSILON;

double **x;	/* feature matrix */
double *w;	/* normal vector of the OSH */
double *csi;
double *alpha;
int *y;		/* class labels */
double theta1,theta2;	/* dual function: theta= theta1+theta2 */
double b;
double epsilon;		/* global minimum argument of theta2*/
List *list;
int lastI,lastJ;
int quiet = 0;

/* parameters */
double tolerance=0.001;
double absoluteTolerance= 0.01;
double wr=0.2;
double C=1;

/* read from input file */
int numExamples, numAttributes;

/* command line: */
/* svm-r_learn <data set> <model file> [-t <tolerance>] [-c <C>] [-w <wr>] [-q]*/
int main(int argc, char* argv[])
{
        int numChanged;		/* number of alpha[i], alpha[j] pairs changed in a single step in the outer loop */
        int examineAll;		/* flag indicating whether the outer loop has to be made on all the alpha[i] */
        int i,k,h;
        double normW2;
        FILE *dataSet;
        FILE *modelFile;
        int ris;
        int correctlyClassified,rejected,correctWithoutReject;
        long start,end;
        float M;
        int examined;

        start=get_runtime();
        if ((argc<2) || (argc>9))
        {
                printf("\nCommand line:\n");
                printf("svm-r_learn <data set> <model file> [-t <tolerance>] [-c <C>] [-w <wr>]\n");
                exit(1);
        }

        /* read command line */
        for(k=3;(k<argc) && ((argv[k])[0] == '-');k++) {
        switch ((argv[k])[1])
        {
                case 't': k++; tolerance= atof(argv[k]); break;
                case 'c': k++; C= atof(argv[k]); break;
                case 'w': k++; wr= atof(argv[k]); break;
                case 'q': k++; quiet = 1; break;
                default: printf("\nunknown parameter %s\n\n",argv[k]);
                exit(0);
        } }

	if (quiet)
	  {
	    printf("\n-----------------------------------\n");
	    printf("tolerance = %f\n",tolerance);
	    printf("absoluteTolerance = %f\n",absoluteTolerance);
	    printf("C = %f\n",C);
	    printf("wr = %f\n",wr);
	    printf("-----------------------------------\n");
	  }

        /* read numAttributes, numExamples */
        if ((dataSet = fopen(argv[1],"r")) == NULL)
        {
                printf("file: %s inesistente",argv[1]); exit(1);
        }

        ris = fscanf(dataSet,"%d %d",&numExamples,&numAttributes);

        memory_allocation();

        /* read examples */
        for (k=0;k<numExamples;k++)
        {
                /* read class label */
                ris = fscanf(dataSet,"%d",&y[k]);

		//printf("%2.1d :: ",y[k]);
                /* read feature vector */
                for (h=0;h<numAttributes;h++) 
		  {
		    ris = fscanf(dataSet,"%lf",&x[k][h]); 
		    //printf("%5.2lf | ",x[k][h]); 
		  }
		//printf("\n");
        }

	if (quiet)
	  {
	    printf("\n-----------------------------------");
	    printf("\nTraining examples: %d",numExamples);
	    printf("\nNumber of features: %d",numAttributes);
	    printf("\n-----------------------------------\n");
	  }
	fclose(dataSet);

        initialize();

        /* outer loop for choosing alpha[i] */
        /* in the first loop all alpha[i] are examined */
        examineAll=1;
        while ((examineAll==1) || (numChanged>0))
        {
                examined=0;
                numChanged=0;
		if (quiet)
		  if (examineAll==1) printf("\nLoop on all alpha[i]"); else printf("\nPartial loop");

                for (i=0; i<numExamples; i++)
                {
                        M=(5*alpha[i]/C);

                        if (examineAll==1)
                                if ( ( (fabs(alpha[i])<zero) && ( (y[i]*(scalar_product(w,x[i])+b)-1) <-absoluteTolerance) ) ||
                                ((alpha[i]>0) && ((y[i]*(scalar_product(w,x[i])+b)-1)>absoluteTolerance) && ((y[i]*(scalar_product(w,x[i])+b)-1)<-M-absoluteTolerance) ))
                                                { numChanged+=examine_example(i); examined++; }
                        if (examineAll==0)
                                if ((alpha[i]>0) && ((y[i]*(scalar_product(w,x[i])+b)-1)>absoluteTolerance) && ((y[i]*(scalar_product(w,x[i])+b)-1)<-M-absoluteTolerance))
                                                { numChanged+=examine_example(i); examined++; }
                }
                /* if last loop was made on all alpha[i] and some of them was changed, next loop is partial */
                /* if the last loop was partial and no alpha[i] was changed, the next loop is made on all alpha[i] */
                if (examineAll==1)  examineAll=0;
                else if (numChanged==0) examineAll=1;
		
		if (quiet)
		  {
		    printf("\n--------------------------------------------------- changed %d/%d\n",numChanged,examined);
		    printf("theta= %f\n",theta1+theta2);
		  }
        }


        /* if epsilon is not in [0,1] it is computed again */
        if ( (epsilon<0) || (epsilon>1) )
        {
                epsilon=compute_final_epsilon();
                b=update_b(lastI,lastJ);
        }

        if (quiet) printf("\nw:");

        normW2=0;
        for (k=0;k<numAttributes;k++) { if (quiet) printf("  %f",w[k]); normW2+=w[k]*w[k]; }
	if (quiet)
	  {
	    printf("\n||w||:    %f",sqrt(normW2));
	    printf("\n1/||w||:  %f",1/sqrt(normW2));
	    printf("\nepsilon/||w||:  %f",epsilon/sqrt(normW2));
	    printf("\nb:    %f",b);
	    printf("\nepsilon   %f",epsilon);
	    printf("\n-----------------------------------\n");
	  }

        /* check the results */
        correctlyClassified=0;
        rejected=0;
        correctWithoutReject=0;
        for (k=0;k<numExamples;k++)
        {
        if( ((scalar_product(w,x[k])+b)*y[k])>0 ) correctWithoutReject++;
                if( ((scalar_product(w,x[k])+b)*y[k])>(epsilon/sqrt(normW2)) ) correctlyClassified++;
        if( fabs((scalar_product(w,x[k])+b))<= (epsilon/sqrt(normW2)) ) rejected++;
        }
        end=get_runtime();

	if ( quiet )
	  {
	    printf("\n\nCPU time %.2f",((float)end-(float)start)/100.0);
	    printf("\n-----------------------------------");
	    printf("\ntraining examples: %d",numExamples);
	    printf("\ncorrectly classified examples (without reject option): %d, percent %.2f%%",correctWithoutReject,((float)correctWithoutReject/numExamples)*100);
	    printf("\n-----------------------------------");
	    printf("\ntraining examples: %d \ncorrectly classified: %d \nrejected %d\n",numExamples,correctlyClassified,rejected);
	    printf("\nCorrect classification rate: %.2f%%",((float)correctlyClassified/numExamples)*100);
	    printf("\nRejection rate: %.2f%%",((float)rejected/numExamples)*100);
	    printf("\nAccuracy: %.2f%%",((float)correctlyClassified/numExamples)*100/(1-((float)rejected/numExamples)));
	    printf("\n-----------------------------------");
	  }

        /* compute the number of examples within the margin */
        correctlyClassified=0; /* !! now it is the number of examples outside the margin */
        rejected=0; /* !! now it is the number of examples inside the margin */
        for (k=0;k<numExamples;k++)
        {
                if( fabs(scalar_product(w,x[k])+b)>(1/sqrt(normW2)) ) correctlyClassified++;
                if( fabs(scalar_product(w,x[k])+b)<= (1/sqrt(normW2)) ) rejected++;
        }

	if ( quiet )
	  {
	    printf("\nnumber of examples outside the margin: %d",correctlyClassified);
	    printf("\nnumber of examples inside the margin: %d",rejected);

	    printf("\n");
	  }
	
        /* write the model file */
        modelFile=fopen(argv[2],"w");
        fprintf(modelFile,"%.4f\n%.13f\n%.13f\n%.13f\n",wr,b,epsilon,sqrt(normW2));
        for (k=0;k<numAttributes;k++) fprintf(modelFile,"%.13f\n",w[k]);
        fclose(modelFile);

        memory_deallocation();
	return 0;
}

void memory_allocation(void)
{
        int k;

        x = (double **) calloc (numExamples, sizeof (double *));

        if (x == NULL)
        { printf ("No room\n"); exit(1); }

        for (k=0; k<numExamples; k++)
        {
                x[k] = (double *) calloc (numAttributes, sizeof (double));
                if (x[k] == NULL)
                { printf ("No room\n"); exit(1); }
        }

        w = (double *) calloc (numAttributes, sizeof (double));
        if (w == NULL)
        { printf ("No room\n"); exit(1); }

        y  = (int *) calloc (numExamples, sizeof (int));
        if (y == NULL)
        { printf ("No room\n"); exit(1); }

        list  = (List *) calloc (numExamples, sizeof (List));
        if (list == NULL)
        { printf ("No room\n"); exit(1); }

        alpha = (double *) calloc (numExamples, sizeof (double));
        if (alpha == NULL)
        { printf ("No room\n"); exit(1); }

        csi = (double *) calloc (numExamples, sizeof (double));
        if (csi == NULL)
        { printf ("No room\n"); exit(1); }
}

void memory_deallocation(void)
{
        int k;

        for (k=0; k<numExamples; k++) free (x[k]);
        free (x);

        free(w);
        free(y);
        free(alpha);
        free(csi);

        for (k=0; k<numExamples; k++) while (list[k] != NULL) list[k]=deleteFirst(list[k]);
        free(list);

}


double scalar_product(const double *v1, const double *v2)
{
        double out=0;
        int k;

        for (k=0; k<numAttributes; k++) out+=v1[k]*v2[k];

        return out;
}


/* alphaTemp is the new alpha[i] component, the one of alpha[j] is computed using the constant c*/
void update_w(int i, int j, double alphaTemp, double c)
{
        const double c1 = y[i] * (alphaTemp - alpha[i]);
        const double c2 = y[j] * (c*y[j] - y[i]*y[j]*alphaTemp - alpha[j]);
		  /*c*y[j] - y[i]*y[j]*alphaTemp = alphaTempJ */
        int k;

        for (k=0; k<numAttributes; k++)  w[k] +=  (c1 * x[i][k] + c2 * x[j][k]);
}

/* compute the new b value without using csi[i] */
double update_b(int i,int j)
{
        double M,bi,bj,biSx,biDx,bjSx,bjDx;

        if (fabs(alpha[i])<zero)	/* alpha[i]==0 */
        {
                if (fabs(alpha[j])<zero)	/* alpha[j]==0 */
                {
                        if (y[i]==1)
                        {
                                /* if y[i]==1 y[j]==1, the maximum of the two left extrema is returned */
                                if (y[j]==1)
                                        if (scalar_product(w,x[i]) < scalar_product(w,x[j])) return (1-scalar_product(w,x[i]));
                                        else return (1-scalar_product(w,x[j]));
                                /* y[i]==1 y[j]==-1 */
                                else
                                        if (-1-scalar_product(w,x[j]) < 1-scalar_product(w,x[i])) return b;
                                        else return ((-scalar_product(w,x[i])-scalar_product(w,x[j]))/2);
                        }
                        /* y[i]==-1 */
                        else
                        {
                                if (y[j]==1)
                                        if (-1-scalar_product(w,x[i])< 1-scalar_product(w,x[j])) return b;
                                        else return ((-scalar_product(w,x[i])-scalar_product(w,x[j]))/2);
                                /* y[j]==-1 */
                                else
                                        if (scalar_product(w,x[i]) > scalar_product(w,x[j])) return (-1-scalar_product(w,x[i]));
                                        else return (-1-scalar_product(w,x[j]));
                        }
                }
                /* alpha[i]==0 alpha[j]>0 */
                else
                {
                        if (y[i]==1) /* y[j]==1 or y[j]==-1 */
                        {
                                bi= 1-scalar_product(w,x[i]);
                                M=(5*alpha[j]/C);
                                if (y[j]==1)
                                {
                                        bjSx= 1-M-scalar_product(w,x[j]);
                                        bjDx= 1-scalar_product(w,x[j]);
                                }
                                else
                                {
                                        bjSx= -1-scalar_product(w,x[j]);
                                        bjDx= M-1-scalar_product(w,x[j]);
                                }
                                if (bi <= bjSx) return ((bjSx+bjDx)/2);
                                if (bi > bjDx) return b;
                                else return ((bjDx+bi)/2);
                        }
                        /* y[i]==-1, y[j]==1 or y[j]==-1 */
                        else
                        {
                                bi= -1-scalar_product(w,x[i]);
                                M=(5*alpha[j]/C);
                                if (y[j]==1)
                                {
                                        bjSx= 1-M-scalar_product(w,x[j]);
                                        bjDx= 1-scalar_product(w,x[j]);
                                }
                                else
                                {
                                        bjSx= -1-scalar_product(w,x[j]);
                                        bjDx= M-1-scalar_product(w,x[j]);
                                }
                                if (bi >= bjDx) return ((bjSx+bjDx)/2);
                                if (bi < bjSx) return b;
                                else return ((bjSx+bi)/2);
                        }
                }
        }
        /*  alpha[i]>0 */
        else
        {

                if (fabs(alpha[j])<zero)
                {
                        if (y[j]==1) /*  y[i]==1 or y[i]==-1 */
                        {
                                bj= 1-scalar_product(w,x[j]);
                                M=(5*alpha[i]/C);
                                if (y[i]==1)
                                {
                                        biSx= 1-M-scalar_product(w,x[i]);
                                        biDx= 1-scalar_product(w,x[i]);
                                }
                                else
                                {
                                        biSx= -1-scalar_product(w,x[i]);
                                        biDx= M-1-scalar_product(w,x[i]);
                                }
                                if (bj <= biSx) return ((biSx+biDx)/2);
                                if (bj > biDx) return b;
                                else return ((biDx+bj)/2);
                        }
                        /* y[j]==-1, y[i]==1 or y[i]==-1 */
                        else
                        {
                                bj= -1-scalar_product(w,x[j]);
                                M=(5*alpha[i]/C);
                                if (y[i]==1)
                                {
                                        biSx= 1-M-scalar_product(w,x[i]);
                                        biDx= 1-scalar_product(w,x[i]);
                                }
                                else
                                {
                                        biSx= -1-scalar_product(w,x[i]);
                                        biDx= M-1-scalar_product(w,x[i]);
                                }
                                if (bj >= biDx) return ((biSx+biDx)/2);
                                if (bj < biSx) return b;
                                else return ((biSx+bj)/2);
                        }
                }
                /* alpha[i]>0 && alpha[j]>0 */
                else
                {
                        M=(5*alpha[i]/C);
                        if (y[i]==1)
                        {
                                biSx= 1-M-scalar_product(w,x[i]);
                                biDx= 1-scalar_product(w,x[i]);
                        }
                        else
                        {
                                biSx= -1-scalar_product(w,x[i]);
                                biDx= M-1-scalar_product(w,x[i]);
                        }
                        M=(5*alpha[j]/C);
                        if (y[j]==1)
                        {
                                bjSx= 1-M-scalar_product(w,x[j]);
                                bjDx= 1-scalar_product(w,x[j]);
                        }
                        else
                        {
                                bjSx= -1-scalar_product(w,x[j]);
                                bjDx= M-1-scalar_product(w,x[j]);
                        }
                        if ( (biSx>bjDx) || (biDx<bjSx) ) return b;
                        if ( (biSx<=bjSx) && (biDx<=bjDx) ) return ((biSx+biDx)/2);
                        if ( (biSx<bjSx) && (biDx>bjDx) ) return ((bjSx+bjDx)/2);
                        if ( biSx<bjDx ) return ((biSx+bjDx)/2);
                        else return ((biDx+bjSx)/2);
                }
        }
}


/* compute the right extreme of the interval to apply the golden section method,
	in the case y[i] != y[j].
	Uses only the values of the i-th example: the values of the j-th one can be found
	from c = y[i] * alphaStar[i] + y[j] * alphaStar[j] */
double right_extreme(int i, int j, double alphaStar, double c, double coefA, double coefB)
{
        double thetaStar;     	/* value of the function in the extreme */
        double theta2Star;      	/* value of theta 2 in the extreme */
        double knownTerm;
        double delta;
        double alphaFirstI,alphaSecondI,alphaFirstJ,alphaSecondJ;
        int sol1 =0, sol2 =0;

        /* first call to compute_theta2: c is needed as well */
        /*  computes theta2 for alpha[i]= alphastar */
        /* the dual function is computed on the extreme */
        theta2Star = compute_theta2(i,j,alphaStar,y[j]*c - y[i]*y[j]*alphaStar,0);
        thetaStar = theta1 + coefA *(alphaStar * alphaStar - alpha[i] * alpha[i]) + coefB *(alphaStar -alpha[i]) + theta2Star;

        knownTerm = theta1 - 0.1 * C * numExamples - (coefA * alpha[i] * alpha[i] + coefB * alpha[i]) - thetaStar;
        delta = coefB * coefB - 4  * coefA  *  knownTerm;

        /* if delta <= 0, the maximum of the dual function is in the extreme,
				so alpha[i] and alpha[j] are not changed */
        if (delta<=0) return alphaStar;

        /* there are two solutions, the best one has to be chosen */
        alphaFirstI = (-coefB + sqrt(delta)) / (2 * coefA);
        alphaSecondI = (-coefB - sqrt(delta)) / (2 * coefA);

        alphaFirstJ = y[j] * (c - y[i] * alphaFirstI);
        alphaSecondJ = y[j] * (c - y[i] * alphaSecondI);

        /* a flag is used to denote whether the solution is in the firstquadrant (sol = 1)
        or not (sol =0, by default) */
        if ((alphaFirstI >=0) && (alphaFirstJ>=0)) sol1 =1;
        if ((alphaSecondI >=0) && (alphaSecondJ>=0)) sol2 =1;

        /* a single solution in the first quadrant */
        if ((sol1 == 1) && (sol2 ==0)) return alphaFirstI;
        if ((sol1 == 0) && (sol2 ==1)) return alphaSecondI;

        /* two solutions in the first quadrant */
        if ((sol1 == 1) && (sol2 ==1))
                if (alphaFirstI > alphaSecondI) return alphaFirstI;
                else return alphaSecondI;

        /* solutions are not feasible: returns the extreme */
        return alphaStar;
}


/* golden section in [sx, dx], uses only alpha[i]  */
double golden_section(int i, int j, double sx, double dx, double coefA, double coefB, double c, double precision)
{
        const double alphaConst=0.61803398875;  
        double lambda,mu,f_lambda,f_mu; /* f_lambda is the value in the function in lambda (the same for f_mu) */

        lambda = sx + (1-alphaConst)*(dx - sx);
        mu = sx + alphaConst*(dx - sx);
        f_lambda=theta1 + coefA * (lambda * lambda - alpha[i] * alpha[i]) + coefB * (lambda - alpha[i]) +  compute_theta2(i,j,lambda,y[j]*c - y[i]*y[j]*lambda,0);
        f_mu= theta1 + coefA*(mu*mu - alpha[i]*alpha[i]) + coefB*(mu - alpha[i]) + compute_theta2(i,j,mu,y[j]*c - y[i]*y[j]*mu,0); 

        while ((dx - sx)>precision)
        {
                if (f_lambda>=f_mu)
                {
                        dx = mu;
                        mu = lambda;
                        lambda = sx + (1-alphaConst)*(dx - sx);
                        f_mu=f_lambda;
                        f_lambda= theta1 + coefA*(lambda*lambda - alpha[i]*alpha[i]) + coefB*(lambda - alpha[i]) + compute_theta2(i,j,lambda,y[j]*c - y[i]*y[j]*lambda,0);
                }
                else
                {
                        sx = lambda;
                        lambda = mu;
                        mu = sx + alphaConst*(dx - sx);
                        f_lambda=f_mu;
                        f_mu= theta1 + coefA*(mu*mu - alpha[i]*alpha[i]) + coefB*(mu - alpha[i]) + compute_theta2(i,j,mu,y[j]*c - y[i]*y[j]*mu,0);
                }
        }
        return ((sx + dx)/2);
}

/* returns 0 if no improvement was found, otherwise returns 1 and updates b, w, csi, theta */
int takestep(int i,int j,double coefA,double coefB,double c)
{
        double alphaNew;
        double epsilonOld;	/* backup of the last value of epsilon */
        double thetaM1,thetaM2;
        double leftExtreme,rightExtreme;	/* extremes for applying the golden section method */

        /* in this case it is encessary to compute the right extreme */
        if (y[i] == y[j])
        {
                leftExtreme =0;
                rightExtreme = fabs(c);
        }
        else
        {
                if (alpha[i]>=alpha[j]) leftExtreme = fabs(c); else  leftExtreme =0;
                rightExtreme = right_extreme(i,j,leftExtreme,c,coefA,coefB);
        }


        /* looks for the maximum of alpha[i] in the chosen interval */
        alphaNew = golden_section(i,j,leftExtreme, rightExtreme,coefA,coefB,c,absoluteTolerance);

        /* exits if alphaNew is identical to the old value */
        /* the two lists i,j could have been changed, the old alpha[i], alpha[j] values are restored */
        if (fabs(alphaNew - alpha[i]) <= absoluteTolerance)
        {
                change_list(list[i],alpha[i]);
                change_list(list[j],alpha[j]);
                return 0;
        }

        /* the value of epsilon is lost in the call to thetaM2 */
        epsilonOld= epsilon;

        /* computes the dual functions with the new alpha[i] and alpha[j] values */
        thetaM1 = theta1 + coefA *(alphaNew*alphaNew - alpha[i]*alpha[i]) + coefB *(alphaNew - alpha[i]);
        thetaM2 = compute_theta2(i,j,alphaNew,y[j]*c - y[i]*y[j]*alphaNew,1);

        /* checks if there has been an improvement: thetaM1 +thetaM2 > theta1 +theta2,
                and |thetaM1 +thetaM2 -theta1 -theta2|/|theta1+theta2| > tolerance,
                that is if ((thetaM1 +thetaM2 -theta1 -theta2) > tolerance*fabs(theta1+theta2))
        */
	if ( quiet ) printf("."); fflush(stdout);
	theta1 = thetaM1;
	theta2 = thetaM2; /* !! epsilon is updated in the call to thetaM2 */
	update_w(i,j,alphaNew,c);
	alpha[i] = alphaNew;
	alpha[j] = c * y[j] - y[i] * y[j] * alphaNew;
	
	lastI=i;	/* needed to compute b in the last step, if it is outside [0,1] */
	lastJ=j;
	
	b=update_b(i,j);
	
	return 1;
}

int examine_example(int i)
{
        int j,m,improved,k;
        int jMemory[2];	/* the two j values to store, 0 the largest, 1 the other one */
        double maxValue,maxPoint;
        double maxValueMemory[2];	/* the two maxima of the function upper-bound, 0 is the largest */
        double c=0;
        double xixi, xixj, xjxj;       	/* temp variables for the scalar product between x[i] and x[j] */
        double coefA, coefB;
        double sum=0;	/* temp variable for the sum */
        double leftExtreme,rightExtreme;  	/* extremes for the golden section */


        improved=0;
        xixi = scalar_product(x[i], x[i]);

        /* initialize the variable so that it is updated at the first call */
        maxValueMemory[0]=-infinity;
        maxValueMemory[1]=-infinity;

        /* loop for choosing j */
        for (j=0; j<numExamples; j++)
        {
                /* excludes the case in which the interval for the golden section is null and the case i=j */
                if ((!((y[i] == y[j]) && (alpha[i] ==0) && (alpha[j] == 0))) && (j != i))
                {
                        /* computes the costant c */
                        c=y[i]*alpha[i]+y[j]*alpha[j];
                        xixj = scalar_product(x[i], x[j]);
                        xjxj = scalar_product(x[j], x[j]);

                        coefA = 0.5 *(2*xixj - xjxj - xixi);

                        /* computes coefB, sum is a temporary variable */
                        sum= 0;
                        for (m=0;m<numAttributes;m++)
                                sum+=(x[j][m]-x[i][m])*(w[m]-y[i]*alpha[i]*x[i][m]-y[j]*alpha[j]*x[j][m]);

                        coefB= y[i]*(sum+c*(xjxj-xixj)-y[j])+1;


                        /* computes the interval to apply the golden section method.
									only alpha[i] is used (leftExtreme and rightExtreme
									refer to alpha[i] only) */
                        if (y[i] == y[j])
                        {
                                leftExtreme =0;
                                rightExtreme = fabs(c);
                        }
                        else if (alpha[i]>=alpha[j]) leftExtreme = fabs(c);
                                else  leftExtreme =0;

                        /* maximum of the function upper-bound */
                        maxPoint = -coefB/(2*coefA);

                        /* checks if the maximum is inside the interval */
                        if (maxPoint<leftExtreme) maxPoint=leftExtreme;
                        if (y[i]==y[j] && maxPoint>rightExtreme) maxPoint=rightExtreme;

                        /* computes the function upper-bound minus -0.1*C*numExamples
                        in the point of maximum */
                        maxValue = coefA*(maxPoint*maxPoint - alpha[i]*alpha[i]) + coefB*(maxPoint - alpha[i]) + theta1;

                        if (maxValue>maxValueMemory[0])
                        {
                                maxValueMemory[1]=maxValueMemory[0];
                                jMemory[1]=jMemory[0];

                                maxValueMemory[0]=maxValue;
                                jMemory[0]=j;
                        }
                        else if (maxValue>maxValueMemory[1])
                                {
                                        maxValueMemory[1]=maxValue;
                                        jMemory[1]=j;
                                }

                }
        }


        /* checks if the j value improves theta (minus -0.1*C*numExamples) */
        maxValueMemory[0]=maxValueMemory[0] - 0.1*C*numExamples;

        if (maxValueMemory[0] - theta1 -theta2 > 0.01*fabs(theta1+theta2))
        {
                k=0;
                while ((improved==0) && (k<2))
                {

                        j=jMemory[k]; 
                        k++;
                        /* computes the constant c */
                        c=y[i]*alpha[i]+y[j]*alpha[j];
                        xixj = scalar_product(x[i], x[j]);
                        xjxj = scalar_product(x[j], x[j]);

                        coefA = 0.5 *(2*xixj - xjxj - xixi);

                        /* computes coefB, sum is a temporary valriable */
                        sum= 0;
                        for (m=0;m<numAttributes;m++)
                                sum+=(x[j][m]-x[i][m])*(w[m]-y[i]*alpha[i]*x[i][m]-y[j]*alpha[j]*x[j][m]);

                        coefB= y[i]*(sum+c*(xjxj-xixj)-y[j])+1;
                        improved=takestep(i,j,coefA,coefB,c);
                }
        }
        return improved;
}


void update_csi(void)
{
        int k;
        List tp;
        int flag;

        for (k=0; k<numExamples; k++)
        {
                tp=list[k];
                while (tp->sx <= epsilon)
                {
                        csi[k]= tp->csi;
                        flag= tp->flag;
                        tp=tp->next;
                }
                if (flag==1) csi[k]= 1+epsilon;
                if (flag==2) csi[k]= 1-epsilon;
        }
}

/* reads from file y[], numExamples, numAttributes, x[][] */
/* theta1=0 since alpha[i]=0 for each i */
/* theta2 must be computed at the first step, by calling test_intervals once with alpha[0]=0,
                then sets the other lists (from 1 to numExamples-1) equal!!*/
/* alpha[] is initialized to zero */
/* b=0 */
/* tolerance can be read from the command line or set to a default value */
/* w is initialized to zero since alpha[i]=0 for each i */
/* 0<wc<=wr<=we */
/* We set:
        wc=0.1; we=1;   alpha=100 is a constant for theta2 */
/* in a single list[0] the minimum of the function is searched for, with the corresponding min and espison values;
        then one gets csi[0] and epsilon.
        One found the value of the function, set theta2=C*numExamples*minimo */
/* in general, theta2= C*(sum from 0 to numExamples-1) */
void initialize(void)
{
        int k;

        srand(time(NULL)); 
        for (k=0; k<numExamples; k++) alpha[k]=0;
        b = 0;

        /* initialize w[i] */
        for (k=0; k<numAttributes; k++) w[k]=0;

	/* initialize the dual function theta */
        theta1 = 0;      /* since alpha[i]=0 */

        if (quiet) printf("\nInitializing the lists:...");
        /* empty lists */
        for (k=0;k<numExamples;k++)
        {        
                list[k] = newList();
                list[k] = putLast(0,0,0,-0.1,0,0,list[k]);
                list[k] = putLast(1,0.1,-0.2,0,0,2,list[k]);
                list[k] = putLast(1.001,0,0,0,0,0,list[k]);
                list[k] = putLast(0,0,0,0,0,0,list[k]); list[k] = putLast(0,0,0,0,0,0,list[k]);
                list[k] = putLast(0,0,0,0,0,0,list[k]); list[k] = putLast(0,0,0,0,0,0,list[k]);
                list[k] = putLast(0,0,0,0,0,0,list[k]); list[k] = putLast(0,0,0,0,0,0,list[k]);
                list[k] = putLast(0,0,0,0,0,0,list[k]); list[k] = putLast(infinity,0,0,0,0,0,list[k]);
        }
        if (quiet) printf("...done");
        /* when alpha [i] =0 for each i, also csi[i]=0 for each i ...
        the minimum of theta2 corresponds to epsilon=0 an is:*/
        theta2 = -0.1*numExamples*C;
        epsilon= 0;
        /* initialize csi[i] */
        for (k=0; k<numExamples; k++) csi[k]=0;
        if (quiet) printf("\nInitialization done");
}


long get_runtime()
{
clock_t start;
start = clock();
return((long)((double)start*100.0/(double)CLOCKS_PER_SEC));
}

