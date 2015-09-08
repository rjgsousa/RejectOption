#ifndef __COMPUTE_THETA2_H__
#define __COMPUTE_THETA2_H__
/* compute the dual function theta2 */

#include "list_functions.c"
#include "intervals.c"

/* compute the value of a polynomial of degree 2 with coefficients a, b, c, at min_point */
#define MINIMUM_VALUE(a, b, c, min_point) ( (a)*(min_point)*(min_point) + (b)*(min_point) + (c) )

extern void update_csi(void);

extern int numExamples;
extern double epsilon;
extern List *list;
extern double *csi;
extern double const zero;


/* minimum: finds the minimum of a polynomial of degree 2
with coefficients a, b, c in a given interval i, j */
double minimum_point(double a,double b,double c,double i,double j)
{
        double min;
        if (fabs(a)<zero) 
        {
                /* if b>0  returns the left extreme
                if b<0 returns the right extreme
                if b=0 and left extreme != -infinity and right extreme !=+infinity returns the mid value,
                else returns j*/
                if (b>0) return i;
                return j;	
        }

        min = -b/(2*a);   
        if (min < i) return i;
        if (min > j) return j;
        return min;
}



/* if changeEpsilon=1 => the global value epsilon is updated */
double compute_theta2(int i, int j,double alphaI, double alphaJ, int changeEpsilon)
{
        struct Old
        {
                double sx, a, b, c;
        };
        struct Old old;
        double min;		/* temporary minimum */
        double sumCoef[3];   	/* sum of coefficients a, b, c */
        int n_list=0;          /* current list (see *current) */
        Node *current;       	/* temporary pointer to the next interval */
        Node *temp;           	/* temporary pointer to avoid nodes with the same left extreme */
        int k;
        double epsilonLocal;
        double globalMinimum;
        List listTemp[numExamples];	/* used to scan lists */

        /* creates the new lists for the new values alphaI, alphaJ */
        change_list(list[i],alphaI);
        change_list(list[j],alphaJ);                  
        sumCoef[0] = 0;     	/* a */
        sumCoef[1] = 0;     	/* b */
        sumCoef[2] = 0;	/* c */

        /* initialize the c coefficient of the note -infinity */
        /* and assigns temporary lists */
        for (k=0; k<numExamples; k++)
        {
                listTemp[k] = list[k];
                sumCoef[0]+=list[k]->a;  /* c */
                sumCoef[1]+=list[k]->b;
                sumCoef[2]+=list[k]->c;
        }

        /* initializes the global minimum, so that it is updated at the first loop */
        globalMinimum=infinity;

        /* initializes old to find the minimum */
        old.sx= 0.0;
        old.a= sumCoef[0];
        old.b= sumCoef[1];
        old.c= sumCoef[2];

        /* initializes current and temp to the node -infinity of the first list */
        current=listTemp[0];
        temp=listTemp[0];

        while (current->sx < 1.001)  	/* while the liste are not +infinity... */
        {
                current=current->next;     /* to avoid a nan */
                for (k = 0; k < numExamples; k++)                                                 /*finds the next interval*/
                {
                        if (listTemp[k]->next->sx  < 1.001)                                       /* skips empty lists */
                                if (listTemp[k]->next->sx < current->sx)            /* find next left extremum */
                                {
                                        current = listTemp[k]->next;
                                        n_list = k;
                                }
                }

                /* if there are no more lists with the same left extremum, */
                /* adds the node temp to finalList */
                if (temp->sx != current->sx)
                {

                        if (temp->sx != old.sx)
                        {
                                min = minimum_point(old.a,old.b,old.c,old.sx,temp->sx);

                                if  (MINIMUM_VALUE(old.a,old.b,old.c,min) <globalMinimum)
                                {
                                        globalMinimum= MINIMUM_VALUE(old.a,old.b,old.c,min);
                                        epsilonLocal= min;
                                }

                                old.sx= temp->sx;
                                old.a= sumCoef[0];
                                old.b= sumCoef[1];
                                old.c= sumCoef[2];
                        }
                }
                temp=current;
                /* updates the coefficients */
                sumCoef[0] = sumCoef[0] - listTemp[n_list]->a + current->a;
                sumCoef[1] = sumCoef[1] - listTemp[n_list]->b + current->b;
                sumCoef[2] = sumCoef[2] - listTemp[n_list]->c + current->c;

                /* leave at least one element in the i-th list */
                if (listTemp[n_list]->next->sx < 1.001) listTemp[n_list]=listTemp[n_list]->next ;
        }

        /* find the minimum in the last interval */
        min = old.sx;   /* the left extreme is the one of the last interval!! it is NOT computed again */

        if  (MINIMUM_VALUE(old.a,old.b,old.c,min) < globalMinimum)
        {
                globalMinimum= MINIMUM_VALUE(old.a,old.b,old.c,min);
                epsilonLocal= min;
        }

        /* if the dual function has to be computed analytically, a csiTemp[] vector has to be used,
                and csi[] must not be updated!!*/

        if (changeEpsilon==1) epsilon=epsilonLocal;
        return (C*globalMinimum);
}


/* returns the epsilon value which minimizes theta2,
        given the optimal values of csi[i] */
double epsilon_analytical(double sx, double dx)
{
        /* numerators of f2 and f3*/
        double numf2;
        double numf3;

        int k;
        double tmp;
        double f2,f3;
        double sumf2f3=0;
        double minimum=infinity;
        double epsilonMinimum=0;

        /* computes the value of sum for f2, f3 for 1000 values of epsilon */
        for (tmp=sx; tmp<=dx+0.00001; tmp+=0.001)
        {
                sumf2f3=0;
                for (k=0; k<numExamples; k++)
                {
                        f2=numf2/(1+exp(-100*(csi[k]-1+tmp)));
                        f3=numf3/(1+exp(-100*(csi[k]-1-tmp)));
                        sumf2f3+=f2+f3;

                }

                if (sumf2f3<minimum)
                {
                        minimum=sumf2f3;
                        epsilonMinimum=tmp;
                }
        }
        return epsilonMinimum;
}


double compute_final_epsilon(void)
{
        struct Old
        {
                double sx, a, b, c;
        };
        struct Old old;
        double min;          	/* temporary minimum */
        double sumCoef[3];  	/* sum of coef. a, b, c */
        int n_list=0;          /* list current (see *current) */
        Node *current;      	/* temporary pointer to next interval*/
        Node *temp;             /* temporary pointer to avoid nodes with the same left extreme*/
        int k;
        double epsilonNon01, minimumNon01;	/* minimum outside [0,1] */
        double epsilon01,minimum01;        	/* minimum inside [0,1] */
        List listTemp[numExamples];      	/* needed to scan lists */
        List finalList;
        List tp;  		/* pointer to finalList */
        double sinistro,destro,a,b,c;  /* needed to find epsilon in a single interval */
        double epsilon_tolerance = 0.01;

        /* creates a list with all the intervals */
        finalList = newList();

        /* pointers used to scan lists */
        for (k=0;k<numExamples;k++) listTemp[k] = list[k];
        sumCoef[0] = 0;       /* a */
        sumCoef[1] = 0;      	/* b */

        /* initializes coeff. c of the node -infinity */
        sumCoef[2] = 0;
        for (k=0; k<numExamples; k++) sumCoef[2]+=list[k]->c;

        /* initializes the minima, to update them at the first loop */
        minimumNon01=infinity;
        minimum01=infinity;

        /* initializes old to find the minimum */
        old.sx= -infinity;
        old.a= sumCoef[0];
        old.b= sumCoef[1];
        old.c= sumCoef[2];

        /* initializes current and temp to the node -infinity of the first list */
        current=listTemp[0];
        temp=listTemp[0];

        while (current->sx != infinity)   
        {
                current=current->next;     /* to avoid a nan */
                for (k = 0; k < numExamples; k++)                                                 /*searches for the next interval */
                {
                        if (listTemp[k]->next->sx  != infinity)                                       /* skips empty lists */
                                if (listTemp[k]->next->sx < current->sx)            /* searches for the next left extreme */
                                {
                                        current = listTemp[k]->next;
                                        n_list = k;
                                }
                }

                if (temp->sx != current->sx)
                {
                        finalList = putLast(temp->sx,sumCoef[0] ,sumCoef[1] ,sumCoef[2] ,0,0,finalList);
                        if (temp->sx != old.sx)
                        {
                                min = minimum_point(old.a,old.b,old.c,old.sx,temp->sx);

                                if  (MINIMUM_VALUE(old.a,old.b,old.c,min) <minimumNon01)
                                {
                                        minimumNon01= MINIMUM_VALUE(old.a,old.b,old.c,min);
                                        epsilonNon01= min;
                                }

                                if ( (MINIMUM_VALUE(old.a,old.b,old.c,min) <minimum01) && (0<=min) && (min<=1) )
                                {
                                        minimum01= MINIMUM_VALUE(old.a,old.b,old.c,min);
                                        epsilon01= min;
                                }

                                old.sx= temp->sx;
                                old.a= sumCoef[0];
                                old.b= sumCoef[1];
                                old.c= sumCoef[2];
                        }
                }
                temp=current;
                sumCoef[0] = sumCoef[0] - listTemp[n_list]->a + current->a;
                sumCoef[1] = sumCoef[1] - listTemp[n_list]->b + current->b;
                sumCoef[2] = sumCoef[2] - listTemp[n_list]->c + current->c;

                if (listTemp[n_list]->next->sx != infinity) listTemp[n_list]=listTemp[n_list]->next ;
        }

        min = old.sx; 

        if  (MINIMUM_VALUE(old.a,old.b,old.c,min) < minimumNon01)
        {
                minimumNon01= MINIMUM_VALUE(old.a,old.b,old.c,min);
                epsilonNon01= min;
        }

        if ( (MINIMUM_VALUE(old.a,old.b,old.c,min) <minimum01) && (0<=min) && (min<=1) )
        {
                minimum01= MINIMUM_VALUE(old.a,old.b,old.c,min);
                epsilon01= min;
        }

         if ( (minimum01 - minimumNon01) < epsilon_tolerance)
        {
                tp=finalList;
                while (tp->sx <= epsilon01)
                {
                        sinistro= tp->sx;
                        a=tp->a;
                        b=tp->b;
                        c=tp->c;
                        tp=tp->next;
                }
                destro= tp->sx;
                printf("\nintervallo= [%f,%f)",sinistro,destro);
                printf("\na= %f, b= %f, c= %f",a,b,c);
                while (finalList != NULL) finalList=deleteFirst(finalList);

                if ( (fabs(a)<zero) && (fabs(b)<zero) && ((destro-sinistro) > 0.1) )
                {
                        update_csi();
                        return epsilon_analytical(sinistro,destro);
                }
                return epsilon01;
        }
        else
        {
                if (epsilonNon01<=0) return 0;
                else return 1;
        }
}
#endif
