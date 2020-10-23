
#include <iostream> 
#include <unordered_map> 
#include <algorithm> 
#include <iterator> 
#include <vector> 

using namespace std; 
int main(int argc, char *argv[]) { 
    unordered_map<std::string, std::string> mymap = {{"Australia", "Canberra"},{"U.S.","Washington"},{"France","Paris"}}; 
    vector<std::string> keys; 
    transform(mymap.begin(), mymap.end(), back_inserter(keys), 
     [](const decltype(mymap)::value_type& pair) { 
      return pair.first; 
     }); 
    sort(keys.begin(), keys.end()); 
    cout << "mymap contains: "; 
    for (auto const& key: keys) { 
     cout << " " << key << ":" << mymap[key]; 
    } 
    cout << endl; 
} 

std::unordered_map<int, int> um {{2, 3}, {6, 7}, {0, 5}};
std::vector<std::pair<int, int>> sorted_elements(um.begin(), um.end());
std::sort(sorted_elements.begin(), sorted_elements.end());