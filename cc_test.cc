#include<iostream>
#include<iomanip>
using namespace std;
int main()
{
const int M = 10, N = 5;
int a[M], b[N], c[N];
int m = 0, n = 0, mn = 0, * pa, * pb, * pc;
cout << "输入数组a的元素个数：" << endl;
cin >> m;
cout << "输入数组b的元数个数：" << endl;
cin >> n;
cout<<"aggg:"<<endl;
for (pa = a; pa < a + m; pa++)
	cin >> *pa;
cout<<"b:"<<endl;

for (pb = b; pb < b + n; pb++)
	cin >> *pb;
cout<<"compare:"<<endl;

for (pa = &a[0], pc = &c[0]; pa < pa + m; pa++){
	for (pb = &b[0]; pb < pb + n; pb++){
		if (*pa == *pb)
		{
			*pc = *pa;
            pc++;
			mn++;
			// break;
		}
    }
}
cout << "交集的元素为：" << endl;
for (pc = c; pc < c + mn; pc++)
	cout << *pc << endl;
return 0;



}