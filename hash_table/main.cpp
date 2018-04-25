#include <iostream>
#include <chrono>



#include "FDict.h"
using namespace std;

int main()
{
    try {

        auto begin = chrono::high_resolution_clock::now();

        Dictionary dict;

        dict.set_hfunc(hash_func_6_forced);

        dict.pars_file("WIM.txt");

        printf("total differ words - %d\n", dict.words_amount_);

        dict.sort_and_save();

        //printf("%u\n",THE_FASTEST_WORDCMP("Abricos","abricos"));

        auto end = std::chrono::high_resolution_clock::now();


        cout<<chrono::duration_cast<chrono::microseconds>(end - begin).count()<<"mcs"<< endl;

    }
    catch (Acorn* acorn)
    {
        acorn->tell_user();
    }
    return 0;
}