





#include <map>
#include <unordered_map>
#include <set>
#include <string>
#include <iostream>
#include <iterator>

using namespace std;

typedef unordered_multimap<string,string> mm; 
typedef unordered_map<string, set<string> > ms; 

ms convert(const mm& m)
{   
    ms r;
    for (mm::const_iterator it = m.begin(); it != m.end(); ++it)    {   
        set<string>& s(r[it->first]);
        // set<string> s(const string & r[it->first]);
        s.insert(it->second);
    }   
    return r;
} 
mm convert_reverse(const ms& mset){
    mm mmap;
    for(auto it = mset.begin();it!=mset.end();it++){
        for(auto it_set = it->second.begin();it_set!=it->second.end();it_set++)
        mmap.insert(make_pair(it->first,*it_set));
    }
    return mmap;
}  


int main()
{   
    mm m;
    m.insert(make_pair("john", "kowalski"));
    m.insert(make_pair("mary", "walker"));
    m.insert(make_pair("john", "kowalski"));
    m.insert(make_pair("john", "smiths"));
    m.insert(make_pair("mary", "doe"));
    m.insert(make_pair("mary", "walker"));

    ms s(convert(m));
    cout<<s.size()<<endl;

    for(auto it_s:s){
        cout<<it_s.first<<" : ";
        auto result = s.find(it_s.first);
        for(auto out:result->second ){
            cout<<out<<" ";
        }
        cout<<endl;
    }

    m.clear();
    m = convert_reverse(s);

    // for (ms::iterator it = s.begin(); it != s.end(); ++it)
    // {   
    //     cout << it->first << ": ";
    //     set<string> &st(it->second);
    //     copy(st.begin(), st.end(), ostream_iterator<string>(cout, ", "));
    //     cout << endl;
    // }   
    return 0;
}   



// #include <iostream> 
// #include <unordered_map> 
// #include <algorithm> 
// #include <iterator> 
// #include <vector> 
// #include <unordered_set>
// using namespace std; 

// template<typename T>
// inline void hash_combine(std::size_t& seed, const T& val)
// {
//     seed ^= std::hash<T>()(val)+0x9e3779b9 + (seed << 6) + (seed >> 2);
// }

// template<typename T>
// inline void hash_val(std::size_t& seed, const T& val)
// {
//     hash_combine(seed, val);
// }

// template<typename T, typename... Types>
// inline void hash_val(std::size_t& seed, const T& val, const Types&... args)
// {
//     hash_combine(seed, val);
//     hash_val(seed, args...);
// }

// template<typename... Types>
// inline std::size_t hash_val(const Types& ...args)
// {
//     std::size_t seed = 0;
//     hash_val(seed, args...);
//     return seed;
// }

// class CustomerEqual
// {
// public:
//     bool operator()(const pair<int,int>& c1, const pair<int,int>& c2) const
//     {        
//         return (c1.first == c2.first && c1.second == c2.second);
//     }
// };

// class CustomerHash
// {
// public:
//     std::size_t operator()(pair<int,int> & c) const
//     {
//         return  hash_val(c.first, c.second);
//     }
// };

// int main(int argc, char *argv[]) { 
//     unordered_set<pair<int,int>,CustomerHash,CustomerEqual> myset ;
//     auto ele1 = pair<int,int>(1,2);
//     myset.insert(make_pair(1,2));


// } 

// using namespace std; 
// int main(int argc, char *argv[]) { 
//     unordered_map<std::string, std::string> mymap = {{"Australia", "Canberra"},{"U.S.","Washington"},{"France","Paris"}}; 
//     vector<std::string> keys; 
//     transform(mymap.begin(), mymap.end(), back_inserter(keys), 
//      [](const decltype(mymap)::value_type& pair) { 
//       return pair.first; 
//      }); 
//     sort(keys.begin(), keys.end()); 
//     cout << "mymap contains: "; 
//     for (auto const& key: keys) { 
//      cout << " " << key << ":" << mymap[key]; 
//     } 
//     cout << endl; 
// } 

// std::unordered_map<int, int> um {{2, 3}, {6, 7}, {0, 5}};
// std::vector<std::pair<int, int>> sorted_elements(um.begin(), um.end());
// std::sort(sorted_elements.begin(), sorted_elements.end());