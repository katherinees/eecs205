import math

a = '00517cc1' #0001932f
expect_sin = '00000000'
expect_cos = '0000fffb'

mydict = {'1':1,'2':2,'3':3,'4':4,'5':5,'6':6,'7':7,'8':8,'9':9,'a':10,'b':11,'c':12,'d':13,'e':14,'f':15,'0':0}

def s16(value):
    return -(value & 0x8000) | (value & 0x7fff)

def convert(hex):
    int_part = hex[:4]
    frac_part = hex[4:]
    decimal = 0
    for i in range(0, 4):
        decimal += float(mydict[frac_part[i]])*pow(16, -i-1)
    # for j in range(0, 4):
    #     decimal += float(mydict[int_part[j]])*pow(16, 3-j)
    int_part = '0x' + int_part
    decimal += s16(int(int_part, 16))
    return decimal

print(convert(a))
print(convert(expect_sin))
print(convert(expect_cos))

# this should be close to 1
print(pow(convert(expect_cos),2)+pow(convert(expect_sin),2))

# def twoscomp(bin):
#     if bin[0] == 1:
#         print('fukc')
#     for i in range (0, len(bin)):
#         print(i)

# print(s16(int('0xffff', 16)))
