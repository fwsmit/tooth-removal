#!/bin/python

import unittest  

from vec_util import *

class TestVecUtil(unittest.TestCase):  

    def generate_ft(self):
        return [[1,2,3], [1,2,4], [1,2,0]]
  
    def test_norm(self):  
        norms = norm_vectors(self.generate_ft())
        self.assertEqual(norms[2], 5)

  
if __name__ == '__main__':  
    unittest.main()  
