#include <cstdint>
#include <cstdio>
#include <iostream>
#include <vector>
#include <fstream>
#include <iomanip>
#include <cmath>
#include <limits>

//15.48


const int FRAC = 48;
const int IC = 63 - FRAC;
const int64_t FPMAX = ((1ULL << IC) - 1) << FRAC;
const int64_t FPMIN = 1ULL << 63;
const int64_t FRAC_MASK = (1UL << FRAC) - 1;
//const int64_t FPMAX = 0x7FFF000000000000;
//const int64_t FPMIN = 0x8000000000000000;

void check_mul_overflow(__int128_t p){

    __uint128_t up = static_cast<__uint128_t>(p);
    int64_t signbit = (up >> 127) & 1;

    if(signbit){

        __uint128_t upsh = (up >> (FRAC*2)) << (FRAC*2);
        __uint128_t mag = (~upsh + 1);
        uint64_t umin = (uint64_t)FPMIN;
        __uint128_t uminls = static_cast<__uint128_t>(umin) << FRAC;

        if( mag >= uminls){
            printf("negative overflow detected!\n");
        }else{
            printf("no negative overflow!\n");
        }
        
    }else{

        int64_t pshift = (int64_t)(p >> (FRAC*2));
        int64_t mshift = FPMAX >> FRAC;
        if( pshift <= mshift){
            printf("no overflow!\n");
        }else{
            printf("unsigned overflow detected!\nproduct is:\t0x%016llX\nmax is:\t\t\t0x%016llX\n",pshift,mshift);
        }
    }
    //int64_t FPMAX = ((1ULL << IC) - 1) << FRAC;

}


int64_t extractfx64(__int128_t p){

    __int128_t middle = (p >> FRAC) & ((1ULL << 63) - 1);
    __uint128_t up = static_cast<__uint128_t>(p);
    __uint128_t signbit = (up >> 127) & 1;
    int64_t result = static_cast<int64_t>((signbit << 63) | middle);

    return result;

}

int64_t mul(int64_t a, int64_t b){

    __int128_t p = static_cast<__int128_t>(a) * static_cast<__int128_t>(b);
    check_mul_overflow(p);
    return extractfx64(p);

}

int64_t to_fixed(double a) { return static_cast<int64_t>(a * static_cast<double>(1ULL << FRAC));}
double to_double(int64_t a) { return (static_cast<double>(a) / (1ULL << FRAC));}



void mul_and_ext_test(){

        std::cout << "beginning mul and ext test..\n";

        std::vector<int64_t> op1;
        std::vector<double> op1f {5631.0,-5631.0,-1.0,2.0,0.1,10.0};
        std::cout << "op1f: ";
        for(auto a: op1f){
            printf("%f ",a);
        }std::cout << std::endl;
        for(auto a: op1f){
            op1.push_back(to_fixed(a));
        }
        std::cout << "op1: ";
        for(auto a: op1){
            printf("0x%016llX ",a);
        }std::cout << std::endl;

        int64_t res {0};
        double resd {0};
        for(int i = 0; i < op1.size(); i++){
            std::cout << "#############################\n";
            for(int j = 0; j < op1.size(); j++){
                printf("fp operands are:\n\t0x%016llX\n\t0x%016llX\n",op1[i],op1[j]);
                printf("f equivelants are:\n\t%f\n\t%f\n",op1f[i],op1f[j]);
                res = mul(op1[i],op1[j]);
                printf("result is: 0x%016llX\n",res);
                resd = to_double(res);
                printf("result in float is: %f\n",(float)resd);
                printf("expected is: %f\n",op1f[i]*op1f[j]);
            }
        }


        std::cout << "exiting mul and ext test..\n";

}



int main(){

    const int N = 10000;
    std::ofstream fx("x.txt"), fy("y.txt"), fz("z.txt");

    int64_t x = to_fixed(-1.0);
    int64_t y = to_fixed(0.1);
    int64_t z = to_fixed(25.0);

    printf("x\t= 0x%016llX\n", (unsigned long long)x);
    printf("y\t= 0x%016llX\n", (unsigned long long)y);
    printf("z\t= 0x%016llX\n", (unsigned long long)z);

    const int64_t sigma = to_fixed(10); // 10
    const int64_t beta  = to_fixed(8.0/3.0); // 2.6666
    const int64_t rho   = to_fixed(28.0); // 28
    const int factor = 8; // dt = 1/256

    for(int i = 0; i < N; i++){

        fx << to_double(x) << '\n';
        fy << to_double(y) << '\n';
        fz << to_double(z) << '\n'; 

        int64_t dx_i = mul(sigma, y - x);
        int64_t dy_i = mul(x,rho-z) - y;
        int64_t dz_i = mul(x,y) - mul(beta,z);

        x = x + (dx_i >> factor);
        y = y + (dy_i >> factor);
        z = z + (dz_i >> factor);

    }


    std::cout << "Simulation complete. Data written to x.txt, y.txt, z.txt\n";

    //mul_and_ext_test();
    return 0;
}