#ifndef __LIST_FUNCTIONS_C__ 
#define __LIST_FUNCTIONS_C__

/* functions to create and manage lists */
#include <stdio.h>
typedef enum boolean { false,true } Boolean; 
typedef struct node {
                                double sx,a,b,c,csi;
                                int flag;                    /* list node */
                                struct node *next; } Node;

typedef Node *List;	/* list */

extern double oldLeft;

/* creates a new node */
Node *newNode(double in_sx, double in_a, double in_b, double in_c, double in_csi, int in_flag, Node *next)
{
        Node *current = (Node*) malloc(sizeof(Node));
        current->sx = in_sx;
        current->a = in_a;
        current->b = in_b;
        current->c = in_c;
        current->csi= in_csi;
        current->flag= in_flag;
        current->next = next;
        return current;
}

/* creates a new list */
List newList(void)
{ return (NULL); }


Boolean isEmpty(List l)
{ return (l==NULL); }

/* push an element in the list */
List putLast(double in_sx, double in_a, double in_b, double in_c, double in_csi, int in_flag, List l)
{
        if (l==NULL) return newNode(in_sx,in_a,in_b,in_c, in_csi, in_flag, NULL);
        l->next = putLast(in_sx,in_a,in_b,in_c, in_csi, in_flag, l->next);
        return l;
}

/* inserts an element in the point current */
List putEl(double in_sx, double in_a, double in_b, double in_c, double in_csi, int in_flag, List current)
{

        if (oldLeft<=0 && in_sx>0) current =current->next;
        if (in_sx <=1.001)
        {
                current->a = in_a;
                current->b = in_b;
                current->c = in_c;
                current->csi= in_csi;
                current->flag= in_flag;
                if (in_sx >0)           /*[0,1]*/
                {
                        current->sx=in_sx;
                        current =current->next;
                }
                else
                {
                        current->sx=0.0;
                }
        }
        oldLeft=in_sx;
        return current;
}

/* deletes the first element of a list */
List deleteFirst(List l)
{
        Node *current;
        if (l==NULL) return NULL;
        current = l;
        l = current->next;
        current->next = NULL;
        free(current);
        return l;
}

/* prints the list values  */
void allList(const List l)
{
        Node *temp;
        if (l==NULL) printf("\nEmpty list\n");
        else
        {
                printf("\n");
                temp=l;
                while (temp!=NULL)
                {
                        printf("\nsx= %f; a= %e; b= %e; c= %e; ",temp->sx,temp->a,temp->b,temp->c);
                        if (temp->a != 0) printf(" -b/2a= %e;",-(temp->b/(2*temp->a)));

                        temp = temp->next;
                }
        }
}
#endif
