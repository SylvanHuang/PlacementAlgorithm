% First Fit Ëã·¨
function [x_Deploy] = FirstFitAlgorithm(PhyPara, LogicPara)
VNF_pool = 1:LogicPara.Nf;
Node_pool = 1:PhyPara.Ns;
for k = 1:length(VNF_pool)
    VNF_ind = VNF_pool(k);
    for i = 1:length(Node_pool)
        Node_ind = Node_pool(i);
        if LogicPara.RequiredFPGA(k) < 
    end
end