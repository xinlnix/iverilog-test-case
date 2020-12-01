
#include<iostream>
#include <vector>
#include <sstream>
using namespace std;

#include <stdio.h>
#include<stdlib.h>
#include<string.h>
// #include <cmath>


// void fun(char * a){
//     char *p = a;
//     while(*p=='*')
//         p++;

//     for(;*p!='\0';p++){
//         if(*p!='*') *a++ = *p;
//     }

//     *a++ = '\0'; 
// }

// int main()
// {
//     char a[80] = "***a**b*cc*";
//     fun(&a[0]);
//     cout<<a;

// }

#define N 10

typedef struct student{
        int id;
        char name[20];
        int s1;
        int s2;
        int s3;
        float sum;
        char level[10];
}STU;

int fun(STU x[], STU h[], int n){
    //caculate sum
    for(int i = 0;i<n;i++){
        x[i].sum = x[i].s1 + x[i].s2 + x[i].s3;
    }
    //find high 
    float highest = x[0].sum;
    for(int i = 0;i<n;i++){
        if(highest<x[i].sum){
            highest = x[i].sum;
        }
    }
    //find lowest 
    float lowest = x[0].sum;
    for(int i = 0;i<n;i++){
        if(lowest > x[i].sum){
            lowest = x[i].sum;
        }
    }
    //
    int return_num = 0;
    for(int i = 0;i<n;i++){
        if(x[i].sum> lowest && x[i].sum < highest){
            strcpy(x[i].level, "pass");
            h[return_num] = x[i];
            return_num +=1;
        }
    }

    return return_num ;
}
 
int main()
{
    STU s1[N] = {{1,"AAA1",81,87,74},{1,"AAA1",81,85,74},{1,"AAA1",81,86,74}};
    cout<<fun(s1,s1,3);
  

}

// #include<iostream>
// #include <vector>
// #include <sstream>
// using namespace std;

// #include <stdio.h>
// #include<stdlib.h>
// // #include <cmath>

// double fun( int a, int n){
//     double sum = 0;
//     for(int i = 1;i<=n;i++){
//         if(i%2 == 0){
//             // sum += pow((double)1/a,i);
//             double c = 1;
//             for(int j=1;j<=i;j++){
//                     c *= (double)1/a;
//             }
//             sum += c;
//         }
//         else{
//             // sum += -pow((double)1/a,i);
//             double c = 1;
//             for(int j=1;j<=i;j++){
//                     c *= (double)1/a;
//             }
//             sum += -c;
//         }
//     }
//     return sum;
// }
 
// int main()
// {
    
//     cout<<fun(2,5);
//     // string s_input = "2020-11-19 14:30:29";
//     // stringstream ss(s_input);
//     // float f1,f2,f3,f4,f5,f6;
//     // char c;
//     // ss>>f1>>c>>f2>>c>>f3;
//     // cout<<f1<<endl;
//     // cout<<c<<endl;
//     // cout<<f2<<endl;
//     // cout<<f3+1.033<<endl;
//     // cout<<1.033 - (int)1.033<<endl;
// }

// #include <cstdio>
// #include <cmath>
// #define percise 0.000000001
 
// double func1(double v,bool id){//原函数
//     if(id) return v*v-3*v+2-exp(v);//方程1 x^2-3*x+2-e^x=0
//         else return v*v*v-v-1;//方程2 x^3-x-1=0
// }
// double func2(double v,bool id){//导数
//     if(id) return 2*v-3-exp(v);//方程1的导数
//         else return 3*v*v-1;//方程2的导数
// }

// void NewtonMethod(double x,bool id){
//     int i=0;
//     printf("-----------------牛顿法-------------------\n");
//     printf("初始值为%f\n",x);
//     while(fabs(func1(x,id)/func2(x,id))>percise){
//         x-=func1(x,id)/func2(x,id);
//         i++;
//         printf("迭代次数为:%d,此时x为%f\n",i,x);
//     }
//     printf("最终结果为%f\n",x);
// }

// int main() {
//     NewtonMethod(0,1);NewtonMethod(2,0);//用牛顿法求两个方程的解
//     return 0;
// }