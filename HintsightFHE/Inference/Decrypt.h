//
//  Decrypt.h
//  HintsightFHE
//
//  Created by Luo Kaiwen on 29/7/24.
//

#ifndef Decrypt_h
#define Decrypt_h

#include <iostream>
#include <vector>
#include <ctime>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#include <fstream>
#include <cstdlib>
#include <cstring>
#include <functional>
#include <condition_variable>
#include <chrono>
#include <thread>
#include <cstdint>
#include <algorithm>
#include <cmath>
//#include <immintrin.h>
#include <string>

using namespace std;


//mod q
inline void modq_dec(int64_t number, int64_t q) {
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


// RLWE Decryption
int64_t Decrypt(int64_t q, int64_t p, int n, const vector<int64_t>& c, const vector<int>& x) {
    // INPUT: modulus q, dimension n, RLWE ciphertext c = (vec(a),b), RLWE key x
    // OUTPUT: Decryption (b + <a,x>) mod q
    int64_t alpha = q/p;
    int64_t ip2 = c[n];
    for (int i = 0; i < n; ++i) {
        ip2 += (c[i]*(int64_t)x[i]);
        modq_dec(ip2, q);
    }

    while (ip2 < 0) {
        ip2 += q;
    }
    
    int64_t temp2 = (ip2 + alpha/2) % q;
    temp2 /= alpha;
    if (temp2 > p/2) {
        temp2 -= p;
    }
    
    return temp2;
}


string audioResultDec(vector<int64_t> enc_result_vector, string file_path) {
    // ======================== Initialization and Information Output ==========================
    srand(time(0));
    //read_vector();

    //set n,q,t for RLWE scheme
    const int n1 = 1024; //2048;                        //polynomial degree
    const int64_t q1 = 3221225473; //206158430209;//2748779069441;//576460752154525697;           //ciphertext modulus
    const int p1 = 6000; //12289;                       //plaintext modulus

    //network parameter
    const int l1 = 512;

    //read LWE secret key
    ifstream fin;
    fin.open(file_path);
    vector<int> x(n1);
    for (int i = 0; i < n1; ++i) {
        fin >> x[i];
    }
    fin.close();
    cout << "read LWE secret key." << endl;
    
    //read encrypted result
    vector<int64_t> ct_ip1(n1+1, 0);
    vector<int64_t> ct_ip2(n1+1, 0);
    
    for (int i = 0 ; i < (n1+1) ; ++i) {
        ct_ip1[i] = enc_result_vector[i];
    }

    for (int j = 0 ; j < (n1+1) ; ++j) {
        ct_ip2[j] = enc_result_vector[j+n1+1];
    }
    
    // Wang Huaxiong
    int bias1 = 62;
    int bias2 = -49;
    // //Wang Xiangning
//    int bias1 = -21;
//    int bias2 = 95;
    
    int64_t dec_ip1 = Decrypt(q1,p1,n1,ct_ip1,x);
    cout << "decryption result of ip1 = " << dec_ip1+bias1 << endl;
    
    int64_t dec_ip2 = Decrypt(q1,p1,n1,ct_ip2,x);
    cout << "decryption result of ip2 = " << dec_ip2+bias2 << endl;
    
    if (dec_ip1+bias1 < dec_ip2+bias2) {
        string result = "yes";
        return result;
    } else {
        string result = "no";
        return result;
    }
}


string imgResultDec(vector<int64_t> enc_result_vector, string file_path) {
    // ======================== Initialization and Information Output ==========================
    srand(static_cast<unsigned int>(time(0)));
    //read_vector();

    //set n,q,t for RLWE scheme
    const int n1 = 1024; //2048;                        //polynomial degree
    const int64_t q1 = 3221225473; //206158430209;//2748779069441;//576460752154525697;           //ciphertext modulus
    const int p1 = 6000; //12289;                       //plaintext modulus

    //network parameter
//    const int l1 = 512;

    //read LWE secret key
    ifstream fin;
    fin.open(file_path);
    vector<int> x(n1);
    for (int i = 0; i < n1; ++i) {
        fin >> x[i];
    }
    fin.close();
    cout << "read LWE secret key." << endl;
    
    //read encrypted result
    vector<int64_t> ct_ip1(n1+1, 0);
    vector<int64_t> ct_ip2(n1+1, 0);
    
    for (int i = 0 ; i < (n1+1) ; ++i) {
        ct_ip1[i] = enc_result_vector[i];
    }

    for (int j = 0 ; j < (n1+1) ; ++j) {
        ct_ip2[j] = enc_result_vector[j+n1+1];
    }
    
    int bias1 = 870;
    int bias2 = -870;
    
    int64_t dec_ip1 = Decrypt(q1,p1,n1,ct_ip1,x);
    cout << "decryption result of ip1 = " << dec_ip1+bias1 << endl;
    
    int64_t dec_ip2 = Decrypt(q1,p1,n1,ct_ip2,x);
    cout << "decryption result of ip2 = " << dec_ip2+bias2 << endl;
    
    string result = to_string(dec_ip1+bias1) + "," + to_string(dec_ip2+bias2);
    return result;
    
//    if (dec_ip1+bias1 < dec_ip2+bias2) {
//        string result = "yes";
//        return result;
//    } else {
//        string result = "no";
//        return result;
//    }
}

#endif /* Decrypt_h */
