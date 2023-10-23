
#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys
import vmaf_compare

count = len(sys.argv)

if count >= 3 :
    reference_url = sys.argv[1]
    source_url = sys.argv[2]
    result = vmaf_compare.getVmafValue(reference_url, source_url)
    print(result)