#ifndef __INTERVALS_C__
#define __INTERVALS_C__
#include "list_functions.c"

/* defines intervals.
   input: a pointer to the list to be changed and the alpha value to insert */

extern double wr;
extern const double infinity;
extern double C;
double oldLeft;

/* flag denotes:
   flag= 0         =>      csi= <constant>
   flag= 1         =>      csi= 1+epsilon
   flag=2          =>      csi= 1-epsilon          */

/* tp is a pointer to the i-th list;        alpha= alpha[i] */
void change_list( List tp, double alpha ) {

  const double w = (wr - 0.1);
  const double _04w = (0.4*w);
  const double alphaOnC= alpha/C;
  const double alphaOnC2= alphaOnC*alphaOnC;
  const double sqrt044=sqrt(0.44);
  const double _5alphaOnC = 5*alphaOnC;
  const double _25alphaOnC2 = 2.5*alphaOnC2;
  double x,x2;
  int k;

  oldLeft=-infinity;
  /* 1 */
  if (alphaOnC<= sqrt(0.08))                       /* case A */
    {

      /* 1.1 */       tp=putEl(-infinity,0,0,0.8-w,0,0,tp);
      /* 1.2 */       tp=putEl(5*(alphaOnC-sqrt(alphaOnC2 + 0.36 - _04w))-1,0.1,(0.2 - alphaOnC), -alphaOnC, 0, 1,tp);
      /* 1.3 */       tp=putEl(-1,0,0,-0.1,0,0,tp);
      /* 1.4 */       tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
      /* 1.5 */       tp=putEl(1-5*(alphaOnC-sqrt(alphaOnC2 + _04w)),0,0,w-0.1,0,0,tp);
    }

  /* 2 */
  else if ((alphaOnC<= (sqrt(0.11-0.1*w)+0.2)) && (alphaOnC <= sqrt(0.44- _04w)))   /* caso B */
    {
      /* 2.1 */       tp=putEl(-infinity,0,0,-_25alphaOnC2+1-w,_5alphaOnC,0,tp);
      /* 2.2 */       tp=putEl(5*(alphaOnC-sqrt(0.44-_04w))-1,0.1,0.2 - alphaOnC,-alphaOnC,0,1,tp);
      /* 2.3 */       if (alphaOnC > 0.3)
	{
	  /* 2.3.1 */     tp=putEl(-1,0,0,-0.1,0,0,tp);               /* a1 */
	  /* 2.3.2 */     tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2 - alphaOnC,0.2-alphaOnC,0,1,tp);
	  /* 2.3.3 */
	  x= 1+(w/(0.4-2*alphaOnC));
	  if ((alphaOnC > (0.2 + 0.5*w)) && (alphaOnC > (0.2 + sqrt(0.1*w))) && ((0.1*x*x - alphaOnC*x + 0.2) < 0))
	    {
	      /* 2.3.3.1 */   tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp);      /* a2 */
	      /* 2.3.3.2 */   tp=putEl(1-x,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
	      /* 2.3.3.3 */   tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
	    }
	  /* 2.3.4 */     else if ((alphaOnC>sqrt044) && (alphaOnC < 0.8) && (alphaOnC > (0.5+sqrt(0.09-0.1*w))))
	    {

	      /* 2.3.4.1 */   tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp);      /* b2 */
	      /* 2.3.4.2 */   tp=putEl(4-_5alphaOnC,0,0,-_25alphaOnC2 +1,_5alphaOnC,0,tp);
	      /* 2.3.4.3 */   tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
	      /* 2.3.4.4 */   tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
	    }
	  /* 2.3.5 */     else
	    {
	      /* 2.3.5.1 */   tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp);       /* d2 */
	      /* 2.3.5.2 */   if ((alphaOnC2>=0.08+_04w) && (alphaOnC<=0.3+w) && ((alphaOnC<=0.4) || ((alphaOnC>0.4) && (alphaOnC>0.3+0.5*w))))
		{
		  /*2.3.5.2.1*/   tp=putEl(1-5*(alphaOnC-sqrt(alphaOnC2-0.08)),0,0,-0.1,0,0,tp);   /* a3 */
		  /*2.3.5.2.2*/   tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		  /*2.3.5.2.3*/   tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		}
	      /*2.3.5.3*/               else
		{
		  /*2.3.5.3.1*/   tp=putEl(1-5*(alphaOnC-sqrt(alphaOnC2-0.08)),0,0,-0.1,0,0,tp);      /*b3*/
		  /*2.3.5.3.2*/   if ((alphaOnC<=sqrt(0.08+_04w)) && (alphaOnC<=0.2+0.5*sqrt(0.08+_04w)))
		    {
		      /*2.3.5.3.2.1*/ tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);        /*a4*/
		      /*2.3.5.3.2.2*/ tp=putEl(1-5*(alphaOnC-sqrt(0.08+_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		    }
		  /*2.3.5.3.3*/   else
		    {     

		      x=5*(alphaOnC-sqrt044);
		      x2=((2*alphaOnC-0.6-w)/(2*alphaOnC-0.4));
		      if ((alphaOnC<=sqrt044) && (alphaOnC>=sqrt(0.11)+0.2) && (alphaOnC>=sqrt(0.44-_04w)) && (x>=x2))
			{

			  /*2.3.5.3.3.1*/ tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);       /*b4*/
			  /*2.3.5.3.3.2*/ tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
			  /*2.3.5.3.3.3*/ tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			  /*2.3.5.3.3.4*/ tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			}
		      /*2.3.5.3.4*/   else
			{
			  if ((alphaOnC<=(0.3+0.5*w)) && (alphaOnC>=(0.2+sqrt(0.02+0.1*w))) && ((0.1*x2*x2-alphaOnC*x2-1.1)<(-_25alphaOnC2)) && ((0.1*x2*x2-alphaOnC*x2)<w))  /* !!! ERRORE !!! */ /* modificato da Fumera */
			    {
			      /*2.3.5.3.4.1*/         tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);        /*c4*/
			      /*2.3.5.3.4.2*/         tp=putEl(1-x2,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /*2.3.5.3.4.3*/         tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			  /*2.3.5.3.5*/   else
			    {
			      /*2.3.5.3.5.1*/         tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);       /*d4*/
			      /*2.3.5.3.5.2*/         tp=putEl(1-5*(alphaOnC-sqrt(alphaOnC2+_04w)),0,0,w-0.1,0,0,tp);
			      /*2.3.5.3.5.3*/         tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /*2.3.5.3.5.4*/         tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			}
		    }
		}
	    }
	}
      /*2.3.bis*/     else if ( (alphaOnC2>=0.08+_04w) && (alphaOnC<=0.3+w) && ( (alphaOnC<=0.4) || ( (alphaOnC>0.4) && (alphaOnC>0.3+0.5*w)) ))
	{
	  x=5*(alphaOnC-sqrt(alphaOnC2-0.08-_04w));
	  tp=putEl(-1,0,0,-0.1,0,0,tp);   /*b'1*/
	  tp=putEl(x-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
	  tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
	}
      /* 2.4 */       else
	{
	  /*2.4.1*/       tp=putEl(-1,0,0,-0.1,0,0,tp);      /*b1*/
	  /*2.4.2*/       x= 5*(alphaOnC-sqrt(alphaOnC2+_04w));
	  if ((alphaOnC<=sqrt(0.44-_04w)) && (2-x<=_5alphaOnC) && (0.1*x*x+(alphaOnC-0.4)*x+0.6>2*alphaOnC))
	    {
	      /*2.4.2.1*/     tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);       /*a2*/
	      /*2.4.2.2*/     tp=putEl(1-x,0,0,w-0.1,0,0,tp);
	      /*2.4.2.3*/     tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
	      /*2.4.2.4*/     tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
	    }
	  /*2.4.3*/       else
	    {
	      x=5*(alphaOnC-sqrt044);
	      x2=((2*alphaOnC-0.6-w)/(2*alphaOnC-0.4));
	      if ((alphaOnC<=sqrt044) && (alphaOnC>=0.2+0.5*sqrt044) && ((x*x*0.1-alphaOnC*x)<w) && (x>=x2))
		{
		  /*2.4.3.1*/        tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
		  /*2.4.3.2*/        tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
		  /*2.4.3.3*/        tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		  /*2.4.3.4*/        tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		}
	      /*2.4.4*/       else
		{
		  x=5*(alphaOnC-sqrt(0.08+_04w));
		  if ((alphaOnC<=sqrt(0.08+_04w)) && (2-x>=_5alphaOnC) && (0.1*x*x-alphaOnC*x<w))
		    {
		      /*2.4.4.1*/        tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);    /*c2*/
		      /*2.4.4.2*/        tp=putEl(1-x,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		    }
		  /*2.4.5*/       else
		    {
		      /*2.4.5.1*/     tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);    /*d2*/
		      /*2.4.5.2*/     tp=putEl((0.2+w)/(2*alphaOnC-0.4),0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		      /*2.4.5.3*/     tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		    }
		}
	    }
	}

    }
  /* 3 */
  else if ((alphaOnC<=(sqrt(0.09-0.1*w)+0.2)) && (alphaOnC>=sqrt(0.44-_04w)))      /* caso C */
    {
      /*3.1*/ tp=putEl(-infinity,0,0,-_25alphaOnC2+1-w,_5alphaOnC,0,tp);
      /*3.2*/ tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC,0,1,tp);
      /*3.3*/ x=((2*alphaOnC-0.4-w)/(2*alphaOnC-0.4));
      if ((alphaOnC>=0.2+0.5*w) && (alphaOnC>=0.2+sqrt(0.1*w)) && (0.1*x*x-alphaOnC*x<-0.2) && (0.1*x*x-alphaOnC*x<0.9-_25alphaOnC2))
	{
	  /*3.3.1*/       tp=putEl(0,0.1,alphaOnC-0.2,-alphaOnC+0.2,0,2,tp);       /*a1*/
	  /*3.3.2*/       tp=putEl(1-x,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
	  /*3.3.3*/       tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
	}
      /*3.4*/ else if((alphaOnC>=sqrt(_04w)) && (alphaOnC<=(0.2+0.5*sqrt(_04w))) && (alphaOnC>=sqrt(_04w+0.08)))
	{
	  /*3.4.1*/       tp=putEl(0,0.1,alphaOnC-0.2,-alphaOnC+0.2,0,2,tp);        /*b1*/
	  /*3.4.2*/       tp=putEl(1-5*(alphaOnC-sqrt(_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
	}
      /*3.5*/ else
	{
	  /*3.5.1*/       tp=putEl(0,0.1,alphaOnC-0.2,-alphaOnC+0.2,0,2,tp);        /*c1*/
	  /*3.5.2*/       tp=putEl(1-5*(alphaOnC-sqrt(alphaOnC2-0.08)),0,0,-0.1,0,0,tp);
	  /*3.5.3*/       tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
	  /*3.5.4*/       tp=putEl(1-5*(alphaOnC-sqrt(0.08+_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
	}
    }
  /*4*/
  else            /* caso D */
    {
      /* 4.1 */       tp=putEl(-infinity,0,0,-_25alphaOnC2+1-w,_5alphaOnC,0,tp);
      /* 4.2 */       x= 5*(alphaOnC-sqrt(_04w));
      if ( (alphaOnC >= 0.2+sqrt(_04w)) && ( (2-x<=0 && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC+_25alphaOnC2-1.1>=0) && (_25alphaOnC2>=0.2+w)) || (2-x>0 && (alphaOnC2>=0.44) && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC+_25alphaOnC2-0.9>=0))))
	{
	  /* 4.2.1 */tp=putEl(1-_5alphaOnC,0.1,alphaOnC-0.2,1.1-alphaOnC-w,0,2,tp);	/* a1 */
	  /* 4.2.2 */if (alphaOnC<=sqrt044)	 
	    {
	      /* 4.2.2.1 */	tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);	/* a2 */
	      /* 4.2.2.2 */	tp=putEl(5*(alphaOnC-sqrt044)-1,0.1,alphaOnC-0.2,-alphaOnC,0,1,tp);
	      /* 4.2.2.3 */	x=5*(alphaOnC-sqrt(alphaOnC2-0.08));
	      if ((0<=x) && (x<=1))
		{
		  /* 4.2.2.3.1 */	tp=putEl(-1,0,0,-0.1,0,0,tp);	/* a3 */
		  /* 4.2.2.3.2 */	tp=putEl(x-1,0.1,0.2-alphaOnC,0.2-alphaOnC,0,1,tp);
		  /* 4.2.2.3.3 */
		  if (    ((0<=x)  &&  (x<=1)) && ( 0.1*(2-x)*(2-x)-(2-x)*alphaOnC+0.2+w>=0 ))
		    {
		      /* 42233.1 */	tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp);	/* a4 */
		      /* 42233.2 */	x2=5*(alphaOnC-sqrt(alphaOnC2-0.08-_04w));
		      if ( (alphaOnC2 >= 0.08-_04w) && ((1<=x2)&&(x2<=2)))
			{
			  /* 42233.2.1 */		tp=putEl(1-x,0,0,-0.1,0,0,tp);	/* a5 */
			  /* 42233.2.2 */       	tp=putEl(x2-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			  /* 42233.2.3 */		tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			}
		      /* 42233.3 */	else
			{
			  /* 42233.3.1 */ tp=putEl(1-x,0,0,-0.1,0,0,tp);	/* b5 */
			  /* 42233.3.2 */ x2=(2*alphaOnC-0.6-w)/(2*alphaOnC-0.4);
			  if ( (x2<=0) && (2-x2<=_5alphaOnC) && (0.1*x2*x2-x2*alphaOnC<=w) && (0.1*x2*x2-x2*alphaOnC<=1.1-_25alphaOnC2) )
			    {
			      /* 422333.2.1 */tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* a6 */
			      /* 422333.2.2 */tp=putEl(1-x2,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /* 422333.2.3 */tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			  else
			    {
			      /* 42233.3.3 */	x2=5*(alphaOnC-sqrt044 );	 
			      if ( (x2<=0) && (2-x2<=_5alphaOnC) && (0.1*x2*x2-x2*alphaOnC<=w) && (0.1*(2-x2)*(2-x2) - (2-x2)*alphaOnC+w>= 0.9-_25alphaOnC2) )
				{
				  /* 422333.3.1 */tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b6 */
				  /* 422333.3.2 */tp=putEl(1-x2,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
				  /* 422333.3.3 */tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				  /* 422333.3.4 */tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			      /* 42233.3.4 */ else
				{
				  x2=5*(alphaOnC-sqrt(0.08+_04w));
				  if ( (alphaOnC<=sqrt(0.08+_04w))&&(alphaOnC<=0.2+0.5*sqrt(0.08+_04w)))
				    {
				      /* 422333.4.1 */tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* c6 */
				      /* 422333.4.2 */tp=putEl(1-x2,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				  /* 42233.3.5 */ else
				    {
				      /* 422333.5.1 */tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* d6 */
				      /* 422333.5.2 */tp=putEl(1-5*(alphaOnC-sqrt(alphaOnC2+_04w)),0,0,w-0.1,0,0,tp);
				      /* 422333.5.3 */tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				      /* 422333.5.4 */tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				}
			    }
			}
		    }
		  /* 4.2.2.3.4 */	else
		    {
		      /* 42234.1 */	tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp);	/* b4 */
		      /* 42234.2 */	tp=putEl(w/(2*alphaOnC-0.4),0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		      /* 42234.3 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		    }
		}
	      /* 4.2.2.4 */	else
		{
		  x= 5*(alphaOnC-sqrt(alphaOnC2-0.08-_04w));
		  if ( (alphaOnC2>=_04w+0.08) && ((1<=x)&&(x<=2)) )
		    {
		      /* 4.2.2.4.1 */	tp=putEl(-1,0,0,-0.1,0,0,tp);	/* b3 */
		      /* 4.2.2.4.2 */	tp=putEl(x-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		      /* 4.2.2.4.3 */          tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		    }
		  /* 4.2.2.5 */           else
		    {
		      /* 4.2.2.5.1 */ tp=putEl(-1,0,0,-0.1,0,0,tp);	/* c3 */
		      /******* Begin A26 *******/
		      /* 4.2.2.5.2 */	x=5*(alphaOnC-sqrt(alphaOnC2+_04w));
		      if ( (2-x<=_5alphaOnC) && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC>=-0.2) && (alphaOnC<=sqrt(0.44-_04w)) )
			{
			  /* 42252.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* a26 */
			  /* 42252.2 */	tp=putEl(1-x,0,0,w-0.1,0,0,tp);
			  /* 42252.3 */	tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			  /* 42252.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			}
		      /* 4.2.2.5.3 */	else
			{
			  x=(2*alphaOnC-0.6-w)/(2*alphaOnC-0.4);
			  if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && (0.1*x*x-x*alphaOnC<=1.1-_25alphaOnC2) )
			    {
			      /* 42253.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
			      /* 42253.2 */	tp=putEl(1-x,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /* 42253.3 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			  /* 4.2.2.5.4 */   else
			    {
			      x=5*(alphaOnC-sqrt044);	 
			      if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && ((0.4-2*alphaOnC)*x<=(0.6-2*alphaOnC+w)) )
				{
				  /* 42254.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* c26 */
				  /* 42254.2 */	tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
				  /* 42254.3 */	tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				  /* 42254.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			      /* 4.2.2.5.5 */	else
				{
				  /* 42255.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
				  /* 42255.2 */	tp=putEl(1-5*(alphaOnC-sqrt(0.08+_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			    }
			}                     /******* End A26 ******/
		    }
		}
	    }
	  /* 4.2.3 */else         
	    {
	      x=5*(alphaOnC-sqrt(_04w));
	      x2=5*(alphaOnC-0.6);
	      if ((0<=x2) && (x2<=1))
		{
		  /*4.2.3.1*/     tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);       /*b2*/
		  /*4.2.3.2*/     tp=putEl(x2-1,0.1,0.2-alphaOnC,0.2-alphaOnC,0,1,tp);
		  /*4.2.3.3*/     if (((0.6<=alphaOnC) && (alphaOnC<=0.8)) && (x2>=((2*alphaOnC-0.4-w)/(2*alphaOnC-0.4))))
		    {
		      /*4.2.3.3.1*/   tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp);        /*a7*/
		      /*4.2.3.3.2*/   tp=putEl(1-x2,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
		      /*4.2.3.3.3*/   tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		      /*4.2.3.3.4*/   tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		    }
		  /*4.2.3.4*/     else
		    {
		      /*4.2.3.4.1*/   tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp);         /*b7*/
		      /*4.2.3.4.2*/   tp=putEl(w/(2*alphaOnC-0.4),0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		      /*4.2.3.4.3*/   tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		    }
		}
	      /*4.2.4*/   else
		{
		  /*4.2.4.1*/     tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);        /*c2*/
		  /*4.2.4.2*/     tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		  /*4.2.4.3*/     tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		}
	    }
	} 
      /*4.3*/    else
	{
	  x=(2*alphaOnC-1.5+w)/(2*alphaOnC-0.4);
	  if ( (x<=0) && ((2-x)<=_5alphaOnC) && ((0.1*x*x-x*alphaOnC)<=(0.9-w)) && ((0.1*x*x-x*alphaOnC)<=(-_25alphaOnC2+1.1)) )
	    {
	      /*4.3.1*/ tp=putEl(1-_5alphaOnC,0.1,alphaOnC-0.2,1.1-alphaOnC-w,0,2,tp);   /*b1*/
	      /*4.3.2*/ tp=putEl(x-1,0.1,0.2-alphaOnC,-alphaOnC,0,1,tp);
	      /*4.3.3*/ x=5*(alphaOnC-sqrt(alphaOnC2-0.08));
	      if (x<=1)
		{
		  /*4.3.3.1*/tp=putEl(-1,0,0,-0.1,0,0,tp);        /*a9*/
		  /*4.3.3.2*/tp=putEl(x-1,0.1,0.2-alphaOnC,0.2-alphaOnC,0,1,tp);
		  /*4.3.3.3*/if ( (0.1*(2-x)*(2-x)-(2-x)*alphaOnC) >= (-0.2-w) )
		    {
		      /*4.3.3.3.1*/tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp);    /*a10*/
		      /*4.3.3.3.2*/if (alphaOnC<=(0.3+0.5*w))
			{
			  /*4.3.3.3.2.1*/tp=putEl(1-x,0,0,-0.1,0,0,tp);   /*a11*/
			  /******* Begin A26 *******/
			  /* 4.3.3.3.22 */x=5*(alphaOnC-sqrt(alphaOnC2+_04w));
			  if ( (2-x<=_5alphaOnC) && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC>=-0.2) && (alphaOnC<=sqrt(0.44-_04w)) )
			    {
			      /* 42252.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* a26 */
			      /* 42252.2 */	tp=putEl(1-x,0,0,w-0.1,0,0,tp);
			      /* 42252.3 */	tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /* 42252.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			  /* 4.2.2.5.3 */	else
			    {
			      x=(2*alphaOnC-0.6-w)/(2*alphaOnC-0.4);
			      if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && (0.1*x*x-x*alphaOnC<=1.1-_25alphaOnC2) )
				{
				  /* 42253.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
				  /* 42253.2 */	tp=putEl(1-x,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				  /* 42253.3 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			      /* 4.2.2.5.4 */   else
				{
				  x=5*(alphaOnC-sqrt044);	 
				  if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && ((0.4-2*alphaOnC)*x<=(0.6-2*alphaOnC+w)) )
				    {
				      /* 42254.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
				      /* 42254.2 */	tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
				      /* 42254.3 */	tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);

				      /* 42254.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				  /* 4.2.2.5.5 */	else
				    {
				      /* 42255.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
				      /* 42255.2 */	tp=putEl(1-5*(alphaOnC-sqrt(0.08+_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				}
			    }                     /******* End A26 *******/
			}
		      /*4.3.3.3.3*/  else
			{
			  /*43333.1*/     tp=putEl(1-x,0,0,-0.1,0,0,tp);  /*b11*/
			  /*43333.2*/     tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			  /*43333.3*/     tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			}
		    }
		  /*4.3.3.4*/      else
		    {
		      /*4.334.1*/     tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp); /*b10*/
		      /*4.334.2*/     tp=putEl(w/(2*alphaOnC-0.4),0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		      /*4.334.3*/     tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		    }
		}
	      /*4.3.4*/      else
		{
		  x=5*(alphaOnC-sqrt(alphaOnC2-0.08-_04w));
		  if ((1<=x) && (x<=2) && (x<=_5alphaOnC) && (alphaOnC2>=(0.08+_04w)))
		    {
		      /*434.1*/               tp=putEl(-1,0,0,-0.1,0,0,tp);   /*b9*/
		      /*434.2*/               tp=putEl(x-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		      /*434.3*/               tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		    }
		  else
		    {
		      /*435.1*/                       tp=putEl(-1,0,0,-0.1,0,0,tp);   /*c9*/
		      /******* Begin A26 *******/      
		      /* 4.3.3.3.22 */x=5*(alphaOnC-sqrt(alphaOnC2+_04w));
		      if ( (2-x<=_5alphaOnC) && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC>=-0.2) && (alphaOnC<=sqrt(0.44-_04w)) )
			{
			  /* 42252.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* a26 */
			  /* 42252.2 */	tp=putEl(1-x,0,0,w-0.1,0,0,tp);
			  /* 42252.3 */	tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			  /* 42252.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			}
		      /* 4.2.2.5.3 */	else
			{
			  x=(2*alphaOnC-0.6-w)/(2*alphaOnC-0.4);
			  if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && (0.1*x*x-x*alphaOnC<=1.1-_25alphaOnC2) )
			    {
			      /* 42253.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
			      /* 42253.2 */	tp=putEl(1-x,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /* 42253.3 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			  /* 4.2.2.5.4 */   else
			    {
			      x=5*(alphaOnC-sqrt044);	 
			      if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && ((0.4-2*alphaOnC)*x<=(0.6-2*alphaOnC+w)) )
				{
				  /* 42254.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
				  /* 42254.2 */	tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
				  /* 42254.3 */	             tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				  /* 42254.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			      /* 4.2.2.5.5 */	else
				{
				  /* 42255.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
				  /* 42255.2 */	tp=putEl(1-5*(alphaOnC-sqrt(0.08+_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			    }
			}                     /******* End A26 *******/
		    }
		}
	    }
	  /*4.4*/     else
	    {
	      x=(2*alphaOnC-1.3+w)/(2*alphaOnC-0.4);
	      if ((x>=0) && ((2-x)<=_5alphaOnC) && ((0.1*x*x-x*alphaOnC)<=-0.2) && ((0.1*x*x-x*alphaOnC+_25alphaOnC2)<=0.9))
		{
		  /*4.4.1*/       tp=putEl(1-_5alphaOnC,0.1,alphaOnC-0.2,1.1-alphaOnC-w,0,2,tp);     /*c1*/
		  /*4.4.2*/       tp=putEl(x-1,0.1,0.2-alphaOnC,0.2-alphaOnC,0,1,tp);
		  /*4.4.3*/       x=5*(alphaOnC-0.6);
		  if ((alphaOnC<=0.8) && (alphaOnC2>=0.44) && (x>=(2*alphaOnC-0.4-w)/(2*alphaOnC-0.4)))
		    {
		      /*4.4.3.1*/     tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp); /*a13*/
		      /*4.4.3.2*/     tp=putEl(1-x,0,0,1-_25alphaOnC2,_5alphaOnC,0,tp);
		      /*4.4.3.3*/     tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
		      /*4.4.3.4*/     tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
		    }
		  /*4.4.4*/   else
		    {
		      x=5*(alphaOnC-sqrt(_04w));
		      if ((0<=x) && (x<=1) && ((2-x)>=(_5alphaOnC)) && ((0.1*x*x-x*alphaOnC)<=-0.2))
			{
			  /*4441*/        tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp); /*b13*/
			  /*4442*/        tp=putEl(1-x,0,0,-_25alphaOnC2+0.1+w,5*alphaOnC,0,tp);
			}
		      else
			{
			  x=5*(alphaOnC-sqrt(alphaOnC2-0.08));
			  if ((alphaOnC>=0.3) &&
			      (( ((2-x)<=_5alphaOnC) && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC+w>=-0.2) && (alphaOnC2<=0.44)) ||
			       (((2-x)>_5alphaOnC) && (alphaOnC2<=0.08+_04w))))
			    {
			      /*4451*/        tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp); /*c13*/        
			      /*4452*/        if (((alphaOnC>=0.4) && (alphaOnC<=(0.3+0.5*w)) && (alphaOnC<=sqrt044)) ||
						  (alphaOnC<0.4))
				{
				  /*44521*/       tp=putEl(1-x,0,0,-0.1,0,0,tp);  /*a14*/
				  /******* Begin A26 *******/        
				  /* 4.3.3.3.22 */x=5*(alphaOnC-sqrt(alphaOnC2+_04w));
				  if ( (2-x<=_5alphaOnC) && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC>=-0.2) && (alphaOnC<=sqrt(0.44-_04w)) )
				    {
				      /* 42252.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* a26 */
				      /* 42252.2 */	tp=putEl(1-x,0,0,w-0.1,0,0,tp);
				      /* 42252.3 */	tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				      /* 42252.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				  /* 4.2.2.5.3 */	else
				    {
				      x=(2*alphaOnC-0.6-w)/(2*alphaOnC-0.4);
				      if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && (0.1*x*x-x*alphaOnC<=1.1-_25alphaOnC2) )
					{
					  /* 42253.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
					  /* 42253.2 */	tp=putEl(1-x,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
					  /* 42253.3 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
					}
				      /* 4.2.2.5.4 */   else
					{
					  x=5*(alphaOnC-sqrt044);	 
					  if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && ((0.4-2*alphaOnC)*x<=(0.6-2*alphaOnC+w)) )
					    {
					      /* 42254.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
					      /* 42254.2 */	tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
					      /* 42254.3 */	tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
					      /* 42254.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
					    }
					  /* 4.2.2.5.5 */else
					    {
					      /* 42255.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
					      /* 42255.2 */	tp=putEl(1-5*(alphaOnC-sqrt(0.08+_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
					    }
					}
				    }                     /******* End A26 *******/
				}
			      /*4453*/                else
				{
				  /*44531*/               tp=putEl(1-x,0,0,-0.1,0,0,tp);  /*b14*/
				  /*44532*/               tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				  /*44533*/               tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			    }
			  else
			    {
			      /*4461*/        tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp); /*d13*/
			      /*4462*/        tp=putEl(w/(2*alphaOnC-0.4),0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /*4463*/        tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			}
		    }
	        }
	      /*4.5*/else
		{
		  x=5*(alphaOnC-sqrt(alphaOnC2-0.08));
		  if ((x<=_5alphaOnC) && ((2-x)<=0) && ((0.1*(2-x)*(2-x)-(2-x)*alphaOnC)>=0.9-w) && (alphaOnC2<=0.08+_04w))
		    {
		      /*4.5.1*/       tp=putEl(1-_5alphaOnC,0.1,alphaOnC-0.2,1.1-alphaOnC-w,0,2,tp);     /*d1*/
		      /*4.5.2*/       tp=putEl(1-x,0,0,0.8-w,0,0,tp);
		      /*4.5.3*/       tp=putEl(5*(alphaOnC-sqrt(alphaOnC2+0.36-_04w))-1,0.1,0.2-alphaOnC,-alphaOnC,0,1,tp);
		      /*4.5.4*/       if (alphaOnC>=0.3)
			{
			  /*4.5.4.1*/     tp=putEl(-1,0,0,-0.1,0,0,tp);   /*a17*/
			  /*4.5.4.2*/     tp=putEl(x-1,0.1,0.2-alphaOnC,0.2-alphaOnC,0,1,tp);
			  /*4.5.4.3*/     if ((0.1*(2-x)*(2-x)-(2-x)*alphaOnC)>=-0.2-w)
			    {
			      /*4.5.4.3.1*/   tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp); /*a19*/
			      /*4.5.4.3.2*/   tp=putEl(1-x,0,0,-0.1,0,0,tp);
			      /*4.5.4.3.3*/
			      /******* Begin A26 *******/        
			      /* 4.3.3.3.22 */x=5*(alphaOnC-sqrt(alphaOnC2+_04w));
			      if ( (2-x<=_5alphaOnC) && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC>=-0.2) && (alphaOnC<=sqrt(0.44-_04w)) )
				{
				  /* 42252.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* a26 */
				  /* 42252.2 */	tp=putEl(1-x,0,0,w-0.1,0,0,tp);
				  /* 42252.3 */	tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				  /* 42252.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			      /* 4.2.2.5.3 */	else
				{
				  x=(2*alphaOnC-0.6-w)/(2*alphaOnC-0.4);
				  if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && (0.1*x*x-x*alphaOnC<=1.1-_25alphaOnC2) )
				    {
				      /* 42253.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
				      /* 42253.2 */	tp=putEl(1-x,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				      /* 42253.3 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				  /* 4.2.2.5.4 */   else
				    {
				      x=5*(alphaOnC-sqrt044);	 
				      if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && ((0.4-2*alphaOnC)*x<=(0.6-2*alphaOnC+w)) )
					{
					  /* 42254.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
					  /* 42254.2 */	tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
					  /* 42254.3 */	tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
					  /* 42254.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
					}
				      /* 4.2.2.5.5 */else
					{
					  /* 42255.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
					  /* 42255.2 */	tp=putEl(1-5*(alphaOnC-sqrt(0.08+_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
					}
				    }
				}                     /******* End A26 *******/
			    }
			  /*4.5.4.4*/            else
			    {
			      /*4.5.4.4.1*/           tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp);         /*c19*/
			      /*4.5.4.4.2*/           tp=putEl(w/(2*alphaOnC-0.4),0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /*4.5.4.4.3*/           tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			}
		      /*2.3.bis*/     else if ( (alphaOnC2>=0.08+_04w) && (alphaOnC<=0.3+w) && ( (alphaOnC<=0.4) || ( (alphaOnC>0.4) && (alphaOnC>0.3+0.5*w)) ))
			{
			  x=5*(alphaOnC-sqrt(alphaOnC2-0.08-_04w));
			  tp=putEl(-1,0,0,-0.1,0,0,tp);   /*b'1*/
			  tp=putEl(x-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			  tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			}
		      /*4.5.5*/      else
			{
			  /*4.5.5.1*/     tp=putEl(-1,0,0,-0.1,0,0,tp);   /*c17*/
			  /*4.5.5.2*/
			  /******* Begin A26 *******/      
			  /* 4.3.3.3.22 */x=5*(alphaOnC-sqrt(alphaOnC2+_04w));
			  if ( (2-x<=_5alphaOnC) && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC>=-0.2) && (alphaOnC<=sqrt(0.44-_04w)) )
			    {
			      /* 42252.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* a26 */
			      /* 42252.2 */	tp=putEl(1-x,0,0,w-0.1,0,0,tp);
			      /* 42252.3 */	tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /* 42252.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			  /* 4.2.2.5.3 */	else
			    {
			      x=(2*alphaOnC-0.6-w)/(2*alphaOnC-0.4);
			      if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && (0.1*x*x-x*alphaOnC<=1.1-_25alphaOnC2) )
				{
				  /* 42253.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
				  /* 42253.2 */	tp=putEl(1-x,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				  /* 42253.3 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			      /* 4.2.2.5.4 */   else
				{
				  x=5*(alphaOnC-sqrt044);	 
				  if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && ((0.4-2*alphaOnC)*x<=(0.6-2*alphaOnC+w)) )
				    {
				      /* 42254.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
				      /* 42254.2 */	tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
				      /* 42254.3 */	tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				      /* 42254.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				  /* 4.2.2.5.5 */else
				    {
				      /* 42255.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
				      /* 42255.2 */	tp=putEl(1-5*(alphaOnC-sqrt(0.08+_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				}
			    }                     /******* End A26 *******/
			}
		    }
		  /*4.6*/         else
		    {
		      /*4.6.1*/       tp=putEl(1-_5alphaOnC,0.1,alphaOnC-0.2,1.1-alphaOnC-w,0,2,tp);     /*e1*/
		      /*4.6.2*/       if (alphaOnC>=0.3)
			{
			  /*4.6.2.1*/     tp=putEl(1-5*(alphaOnC-sqrt(alphaOnC2-0.44+_04w)),0,0,-0.1,0,0,tp);       /*a22*/
			  x=5*(alphaOnC-sqrt(alphaOnC2-0.08));
			  /*4.6.2.2*/     tp=putEl(x-1,0.1,0.2-alphaOnC,0.2-alphaOnC,0,1,tp);
			  /*4.6.2.3*/     if ((0.1*(2-x)*(2-x)-(2-x)*alphaOnC)>=-0.2-w)
			    {
			      /*46231*/       tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp); /*a23*/
			      /*46232*/       if (alphaOnC<=(0.3+0.5*w))
				{
				  /*462321*/      tp=putEl(1-x,0,0,-0.1,0,0,tp);   /*a24*/
				  /*462322*/
				  /******* Begin A26 *******/        /*la numerazione non vale*/
				  /* 4.3.3.3.22 */x=5*(alphaOnC-sqrt(alphaOnC2+_04w));
				  if ( (2-x<=_5alphaOnC) && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC>=-0.2) && (alphaOnC<=sqrt(0.44-_04w)) )
				    {
				      /* 42252.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* a26 */
				      /* 42252.2 */	tp=putEl(1-x,0,0,w-0.1,0,0,tp);
				      /* 42252.3 */	tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				      /* 42252.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				  /* 4.2.2.5.3 */	else
				    {
				      x=(2*alphaOnC-0.6-w)/(2*alphaOnC-0.4);
				      if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && (0.1*x*x-x*alphaOnC<=1.1-_25alphaOnC2) )
					{
					  /* 42253.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
					  /* 42253.2 */	tp=putEl(1-x,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
					  /* 42253.3 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
					}
				      /* 4.2.2.5.4 */   else
					{
					  x=5*(alphaOnC-sqrt044);	 
					  if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && ((0.4-2*alphaOnC)*x<=(0.6-2*alphaOnC+w)) )
					    {
					      /* 42254.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
					      /* 42254.2 */	tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
					      /* 42254.3 */	tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
					      /* 42254.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
					    }
					  /* 4.2.2.5.5 */else
					    {
					      /* 42255.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
					      /* 42255.2 */	tp=putEl(1-5*(alphaOnC-sqrt(0.08+_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
					    }
					}
				    }                     /******* End A26 *******/
				}
			      else
				{
				  /*462331*/      tp=putEl(1-x,0,0,-0.1,0,0,tp);  /*b24*/
				  /*462332*/      tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				  /*462333*/      tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			    }
			  else
			    {
			      /*46241*/       tp=putEl(0,0.1,alphaOnC-0.2,0.2-alphaOnC,0,2,tp); /*b23*/
			      /*46242*/       tp=putEl(w/(2*alphaOnC-0.4),0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /*46243*/       tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			}
		      /*2.3.bis*/     else if ( (alphaOnC2>=0.08+_04w) && (alphaOnC<=0.3+w) && ( (alphaOnC<=0.4) || ( (alphaOnC>0.4) && (alphaOnC>0.3+0.5*w)) ))
			{
			  x=5*(alphaOnC-sqrt(alphaOnC2-0.08-_04w));
			  tp=putEl(-1,0,0,-0.1,0,0,tp);   /*b'1*/
			  tp=putEl(x-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			  tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			}

		      else
			{
			  /*4631*/        tp=putEl(1-5*(alphaOnC-sqrt(alphaOnC2-0.44+_04w)),0,0,-0.1,0,0,tp);       /*c22*/
			  /*4632*/        /******* Begin A26 *******/        /*la numerazione non vale*/
			  /* 4.3.3.3.22 */x=5*(alphaOnC-sqrt(alphaOnC2+_04w));
			  if ( (2-x<=_5alphaOnC) && (0.1*(2-x)*(2-x)-(2-x)*alphaOnC>=-0.2) && (alphaOnC<=sqrt(0.44-_04w)) )
			    {
			      /* 42252.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* a26 */
			      /* 42252.2 */	tp=putEl(1-x,0,0,w-0.1,0,0,tp);
			      /* 42252.3 */	tp=putEl(5*(alphaOnC-sqrt(alphaOnC2-0.08))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
			      /* 42252.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
			    }
			  /* 4.2.2.5.3 */	else
			    {
			      x=(2*alphaOnC-0.6-w)/(2*alphaOnC-0.4);
			      if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && (0.1*x*x-x*alphaOnC<=1.1-_25alphaOnC2) )
				{
				  /* 42253.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
				  /* 42253.2 */	tp=putEl(1-x,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				  /* 42253.3 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				}
			      /* 4.2.2.5.4 */   else
				{
				  x=5*(alphaOnC-sqrt044);
				  if ( (x<=0) && (2-x<=_5alphaOnC) && (0.1*x*x-x*alphaOnC<=w) && ((0.4-2*alphaOnC)*x<=(0.6-2*alphaOnC+w)) )
				    {
				      /* 42254.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);	/* b26 */
				      /* 42254.2 */	tp=putEl(1-x,0,0,-_25alphaOnC2+1,_5alphaOnC,0,tp);
				      /* 42254.3 */	tp=putEl(5*(alphaOnC-sqrt(0.36-_04w))-1,0.1,0.2-alphaOnC,0.2-alphaOnC+w,0,1,tp);
				      /* 42254.4 */	tp=putEl(_5alphaOnC-1,0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				  /* 4.2.2.5.5 */else
				    {
				      /* 42255.1 */	tp=putEl(1,0.1,alphaOnC-0.2,-alphaOnC,0,2,tp);
				      /* 42255.2 */	tp=putEl(1-5*(alphaOnC-sqrt(0.08+_04w)),0,0,-_25alphaOnC2+0.1+w,_5alphaOnC,0,tp);
				    }
				}
			    }                     /******* End A26 *******/
			}
		    }
		}
	    }
	}
    }
  tp->sx=1.001;            /* last node */
}

#endif
