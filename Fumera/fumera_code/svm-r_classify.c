/* svm-r_classify.c */

#include<stdio.h>
#include<stdlib.h>
#include<float.h>
#include<limits.h>
#include<math.h>

double **x;	/* feature vectors */
double *w;	/* normal vector to the OSH */
int *y;		/* class labels */
double b;
double epsilon;
int numExamples,numFeatures;

void training_set_allocation(void)
{
	int k;

        x = (double **) calloc (numExamples, sizeof (double *));

        if (x == NULL)
        { printf ("No room\n"); exit(1); }

        for (k=0; k<numExamples; k++)
        {
                x[k] = (double *) calloc (numFeatures, sizeof (double));
                if (x[k] == NULL)
                { printf ("No room"); exit(1); }
        }

        w = (double *) calloc (numFeatures, sizeof (double));
        if (w == NULL)
        { printf ("No room\n"); exit(1); }

        y  = (int *) calloc (numExamples, sizeof (int));
        if (y == NULL)
        { printf ("No room\n"); exit(1); }
}


void test_set_allocation(void)
{
	int k;

        x = (double **) calloc (numExamples, sizeof (double *));

        if (x == NULL)
        { printf ("No room\n"); exit(1); }

        for (k=0; k<numExamples; k++)
        {
                x[k] = (double *) calloc (numFeatures, sizeof (double));
                if (x[k] == NULL)
                { printf ("No room\n"); exit(1); }
        }

        y  = (int *) calloc (numExamples, sizeof (int));
        if (y == NULL)
        { printf ("No room\n"); exit(1); }
}

void memory_deallocation(void)
{
        int k;

        for (k=0; k<numExamples; k++) free (x[k]);
        free (x);

        free(y);
}


double scalar_product(const double *v1, const double *v2)
{
        double out=0;
        int k;

         for (k=0; k<numFeatures; k++) out+=v1[k]*v2[k];

        return out;
}


int main(int argc, char* argv[])
{

        FILE *dataSet;
	FILE *fileModel;
	FILE *outputFile;
        int ris,k,h;
        int correct,rejected,misclassified;
	double accuracy,wr,w_norm;

	double E,R;
        if (argc!=5)
        {
                printf("\nCommand line:\n");
                printf("svm-r_classify <training set>.train <test set>.test <model> <output file>\n");
                exit(1);
        }


        if ((dataSet = fopen(argv[1],"r")) == NULL)
        {
                printf("file: %s not found",argv[1]); exit(1);
        }

        ris = fscanf(dataSet,"%d %d",&numExamples,&numFeatures);

        training_set_allocation();

        for (k=0;k<numExamples;k++)
        {
                ris = fscanf(dataSet,"%d",&y[k]);

                for (h=0;h<numFeatures;h++) ris = fscanf(dataSet,"%lf",&x[k][h]);

	}
        fclose(dataSet);

	fileModel=fopen(argv[3],"r");
	ris= fscanf(fileModel,"%lf\n%lf\n%lf\n%lf\n",&wr,&b,&epsilon,&w_norm);
	for (k=0;k<numFeatures;k++) ris= fscanf(fileModel,"%lf\n",&w[k]);
	fclose(fileModel);
	correct=0;
        rejected=0;
        for (k=0;k<numExamples;k++)
        {

		if( ((scalar_product(w,x[k])+b)*y[k])>epsilon) correct++;
		if( fabs((scalar_product(w,x[k])+b))<=epsilon) rejected++;
        }
	// Fumeras' original code
	misclassified= numExamples-rejected-correct;
	accuracy= ( (float)correct/numExamples ) / (1-(float)rejected/numExamples);
	
	// mine
	R = (float) rejected/numExamples;
	E = (float) misclassified/numExamples;
	

	outputFile=fopen(argv[4],"a");
	/*      --- 	train		   ----- */
	/* <wr> <reject rate> <error rate> <accuracy> */
	fprintf(outputFile,"%.4f %f %f %f",wr,R,E,accuracy);

	memory_deallocation();

	/* test */

        if ((dataSet = fopen(argv[2],"r")) == NULL)
        {
                printf("file: %s not found",argv[2]); exit(1);
        }

        ris = fscanf(dataSet,"%d %d",&numExamples,&numFeatures);

        test_set_allocation();

        for (k=0;k<numExamples;k++)
        {
                ris = fscanf(dataSet,"%d",&y[k]);

                for (h=0;h<numFeatures;h++) ris = fscanf(dataSet,"%lf",&x[k][h]);

        }

        fclose(dataSet);
	correct=0;
        rejected=0;

        for (k=0;k<numExamples;k++)
        {

		if( ((scalar_product(w,x[k])+b)*y[k])>epsilon) correct++;
		if( fabs((scalar_product(w,x[k])+b))<=epsilon) rejected++;
        }

	misclassified= numExamples-rejected-correct;
	accuracy= ( (float)correct/numExamples ) / (1-(float)rejected/numExamples);

	/* --- 		test	      ----- */
	/* <reject rate> <error rate> <accuracy> */
	fprintf(outputFile," %f %f %f\n",(float)rejected/numExamples,(float)misclassified/numExamples,accuracy);

	memory_deallocation();
	free(w);
	fclose(outputFile);

	return 0;
}
