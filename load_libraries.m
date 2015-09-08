function load_libraries()
    rmpath('../libraries/libsvm/');
    rmpath('../libraries/quadratic_programming/common');
    rmpath('../libraries/quadratic_programming');
    rmpath('../libraries/qpc/binaries');
    rmpath('../libraries/');

    
    addpath('../libraries/libsvm/');
    addpath('../libraries/quadratic_programming/common');
    addpath('../libraries/quadratic_programming');
    addpath('../libraries/qpc/binaries');
    addpath('../libraries');

    rmpath('oSVM/')
    rmpath('LIBSVM_thresholds/')
    rmpath('LIBSVM_weights/')

    addpath('oSVM/')
    addpath('LIBSVM_thresholds/')
    addpath('LIBSVM_weights/')

    return;