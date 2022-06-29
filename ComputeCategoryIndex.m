function [CatIndex,bin]=ComputeCategoryIndex(Cat,Bias)
        
        if Cat==1
            CatIndex=1;
            bin=0;
        elseif Cat==2
            if Bias>0
                CatIndex=2;
                bin=1;
            else 
                CatIndex=8;
                bin=-1;
            end
        elseif Cat==3
            if Bias>0
                CatIndex=3;
                bin=1;
            else 
                CatIndex=7;
                bin=-1;
            end
        elseif Cat==4
            if Bias>0
                CatIndex=4;
                bin=1;
            else 
                CatIndex=6;
                bin=-1;
            end    
        elseif Cat==5
            bin=0;
            CatIndex=5;
        else
            CatIndex=nan(1,1);
        end
end