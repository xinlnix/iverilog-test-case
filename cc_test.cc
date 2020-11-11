



// #include <iostream>
// #include <unordered_set>
// #include <utility>
// using namespace std;
// struct pair_hash
// {
// 	template <class T1, class T2>
// 	std::size_t operator () (std::pair<T1, T2> const &pair) const
// 	{
// 		std::size_t h1 = std::hash<T1>()(pair.first);
// 		std::size_t h2 = std::hash<T2>()(pair.second);

// 		return h1 ^ h2;
// 	}
// };

// int main()
// {
// 	std::unordered_set<std::pair<std::string,int>, pair_hash> set =
// 	{
// 		{"two", 2}, {"one", 1}, {"four", 4}, {"three", 3},{"two", 3},{"two", 2},{"two", 2}
// 	};

// 	for (auto const &p: set) {
// 		std::cout << p.first << ": " << p.second << '\n';
// 	}

// 	auto pp = set.equal_range({"two",x} );
// 	for(auto p = pp.first;p!=pp.second;p++){
// 		cout<<p->first<<" "<<p->second<<endl;
// 	}


// 	return 0;
// }


#include <map>
#include <string>
#include <iostream>
#include <set>
#include <unordered_set>
using namespace std;



int main(int argc, char** argv)
{
    std::map<std::string, set<string> > m;
    // std::map<std::string, set<string> > m;
	// std::unordered_map<string, string>();
	// std::unordered_set<pair<string,string>, std::hash<string>> m;
    // m.insert(pair<string, set<string>>("a", {"b","c"}) );
    // m.insert(pair<string, string>("a", "c") );
    // m.insert(pair<string, string>("a", "d") );
    // m.insert(pair<string, string>("a", "c") );
    // m.insert(pair<string, string>("b", "c") );
    // m.insert(pair<string, string>("b", "c") );
	// auto pp = m.equal_range(pair<string, string>("a","b"));
	// for(auto p = pp.first; p!=pp.second;p++){
	// 	cout<<p->first<<" "<<p->second<<endl;
	// }



	set<string> ss;
	ss.insert("b");
	ss.insert("c");
	m["a"] =  ss;

	// set<string> ss1;
	ss.insert("e");
	ss.insert("c");
	ss.insert("a");
    // m.insert(pair<string, set<string>>("a", ss) );
	m["a"] =  ss;


	// for()

    // m.insert(std::make_pair("A", "B"));
    // m.insert(std::make_pair("A", "C"));
    std::cout << m.size() << std::endl;
	for(auto i: m){
		cout<<i.first<<" value "<<i.second.size()<<endl;
	}
	// auto pp = m.equal_range("a");
	// for(auto p = pp.first; p!=pp.second; p++){
	// 	cout<<p->first<<" value "<<p->second<<endl;
	// }
    return 0;
}



// // #include <map>
// // #include <string>
// // #include <iostream>
// // using namespace std;

// // int main(int argc, char** argv)
// // {
// //     std::multimap<std::string, std::string> m;
// //     m.insert(std::make_pair("A", "B"));
// //     m.insert(std::make_pair("A", "B"));
// //     m.insert(std::make_pair("A", "C"));
// //     std::cout << m.size() << std::endl;
// // 	for(auto i: m){
// // 		cout<<i.first<<" value "<<i.second<<endl;
// // 	}
// // 	auto pp = m.equal_range("A");
// // 	for(auto p = pp.first; p!=pp.second; p++){
// // 		cout<<p->first<<" value "<<p->second<<endl;
// // 	}
// //     return 0;
// // }






// // #include<iostream>
// // #include<iomanip>
// // using namespace std;
// // int main()
// // {
// // const int M = 10, N = 5;
// // int a[M], b[N], c[N];
// // int m = 0, n = 0, mn = 0, * pa, * pb, * pc;
// // cout << "输入数组a的元素个数：" << endl;
// // cin >> m;
// // cout << "输入数组b的元数个数：" << endl;
// // cin >> n;
// // cout<<"aggg:"<<endl;
// // for (pa = a; pa < a + m; pa++)
// // 	cin >> *pa;
// // cout<<"b:"<<endl;

// // for (pb = b; pb < b + n; pb++)
// // 	cin >> *pb;
// // cout<<"compare:"<<endl;

// // for (pa = &a[0], pc = &c[0]; pa < pa + m; pa++){
// // 	for (pb = &b[0]; pb < pb + n; pb++){
// // 		if (*pa == *pb)
// // 		{
// // 			*pc = *pa;
// //             pc++;
// // 			mn++;
// // 			// break;
// // 		}
// //     }
// // }
// // cout << "交集的元素为：" << endl;
// // for (pc = c; pc < c + mn; pc++)
// // 	cout << *pc << endl;
// // return 0;



// // }