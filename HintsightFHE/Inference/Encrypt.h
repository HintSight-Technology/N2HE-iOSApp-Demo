//
//  Encrypt.h
//  HintsightFHE
//
//  Created by Luo Kaiwen on 31/7/24.
//

#ifndef Encrypt_h
#define Encrypt_h

#include <iostream>
#include <vector>
#include <unistd.h>
#include <fstream>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <cstdint>
#include <algorithm>
#include <cmath>
#include <string>

using namespace std;


inline void modq(int64_t number, int64_t q) {
    if (number < 0) {
        int64_t temp = (-1*number)/q + 1;
        number += temp*q;
    }
    if (number >= q) {
        int64_t temp = number/q;
        number -= temp*q;
    }
    if (number >= q/2) {
        number -= q;
    }
    return;
}

inline void modq_poly(vector<int64_t> &a, int n, int64_t q) {
    // INPUT: polynomial a, modulus q
    // OUTPUT: (modified) a mod q, stored in a
    for (int i = 0; i < n; ++i) {
        while (a[i] < 0) {
            a[i] += q;
        }

        while (a[i] >= q) {
            a[i] -= q;
        }

        if (a[i] > (q-1)/2) {
            a[i] -= q;
        }
    }
}

inline void modq_poly_large(vector<int64_t> &a, int n, int64_t q) {
    // INPUT: polynomial a, modulus q
    // OUTPUT: (modified) a mod q, stored in a
    for (int i = 0; i < n; ++i) {
        if (a[i] < 0) {
            int64_t temp = -1 * a[i];
            a[i] += q*(temp/q+1);
        }

        if (a[i] >= q) {
            a[i] -= q*(a[i]/q);
        }

        if (a[i] > (q-1)/2) {
            a[i] -= q;
        }
    }
}

// Addition between polynomials
void add_poly(vector<int64_t> &a, const vector<int64_t> & b, int n, int64_t q) {
    // INPUT: polynomials a and b, modulus q
    // OUTPUT: (a + b) mod q, stored in a
    for (int i = 0 ; i < n ; ++i) {
        a[i] += b[i];
    }
    // mod q
    modq_poly_large(a,n, q);
}

// Scaling
void multi_scale_poly(int64_t t, vector<int64_t> &a, int n, int64_t q) {
    // INPUT: scaler t, polynomial a, modulus q
    // OUTPUT: t*a mod q, stored in a

    for (int i = 0; i < n; ++i) {
        a[i] *= t;
    }
    modq_poly_large(a,n, q);
}

vector<int64_t> mul_poly(const vector<int64_t>& aa,
                         const vector<int64_t>& bb,int n, int64_t q) {
    vector<int64_t> c(n,0);
    for (int i = 0 ; i <n ; ++i) {
        for (int j = 0 ; j < n ; ++j) {
            if (i+j < n) {
                c[i+j] += aa[i]*bb[j];
                modq(c[i+j],q);
            } else {
                c[i+j-n] -= aa[i]*bb[j];
                modq(c[i+j-n],q);
            }
        }
    }
    modq_poly_large(c,n,q);
    return c;
}


vector<vector<int64_t>> RLWE64_Enc(const vector<int64_t>& m,
                                   const vector<vector<int64_t> > & pk, int64_t p, int64_t q) {
    int64_t alpha = q/p;
    int len = pk[0].size();

    vector<vector<int64_t>> ct(2, vector<int64_t>(len,0));

    //generate random polynomial u
    vector<int64_t> u(len,0);
    for (int i = 0; i < len; ++i) {
        int64_t tempa = rand() % 2;
        u[i] = tempa;
    }

    //compute ct[0] = pk[0]u+e1
    vector<int64_t> pk0u = mul_poly(pk[0], u, len, q);

    //Generate e and compute -as+e
    for (int i = 0; i < len; ++i) {
        int64_t indexe = rand()%16;
        int64_t e = 0;
        if (indexe == 0) {
            e = 1;
        }
        else if (indexe == 1) {
            e =- 1;
        }
        pk0u[i] += e;
    }

    modq_poly_large(pk0u,len,q);
    ct[0] = pk0u;

    //compute ct[1] = pk[1]u+e1+alpham
    vector<int64_t> pk1u = mul_poly(pk[1], u, len, q);

    //Generate e and compute -as+e
    for (int i = 0; i < len; ++i) {
    int64_t indexe = rand()%16;
        int64_t e = 0;
        if (indexe == 0) {
            e = 1;
        }
        else if (indexe == 1) {
            e = -1;
        }
        pk1u[i] += e;
        pk1u[i] += (alpha*m[i]);
    }

    modq_poly_large(pk1u, len, q);
    ct[1] = pk1u;

    return ct;
}


vector<vector<int64_t>> vectorEnc(vector<int> pt_img_vector, string pk_file_path) {
    
    srand(time(0));

    //set n,q,t for RLWE scheme
    const int n1 = 1024;//2048;                        //polynomial degree
    const int64_t q1 = 3221225473;//206158430209;//2748779069441;//576460752154525697;           //ciphertext modulus
    const int p1 = 6000;//12289;                       //plaintext modulus

    //network parameter
    const int l1 = 512;

    //read lwe secret key
    ifstream fin;

    //read lwe public key
    fin.open(pk_file_path);
    vector<vector<int64_t>> pk(2, vector<int64_t>(n1,0));
    for (int i=0 ; i < 2 ; ++i) {
        for (int j = 0; j < n1; ++j) {
            fin >> pk[i][j];
        }
    }
    fin.close();
    cout << "Read RLWE public key. " << endl;

    vector<int64_t> input(n1,0);
    for (int i = 0; i < l1; ++i) {
        input[i] = pt_img_vector[i];
    }
    vector<vector<int64_t>> ct = RLWE64_Enc(input,pk,p1,q1);

    return ct;
}


#endif /* Encrypt_h */
