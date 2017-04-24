% First Fit Ëã·¨
function [x_Deploy] = FirstFitAlgorithm(PhyPara, LogicPara)
load('E:\0-qindongrun\Algorithm program\Placement\ScenarioCreationFunctions\DataContainer\InputPara.mat')
VNF_pool = 1:LogicPara.Nf;
Node_pool = 1:PhyPara.Ns;
x_Deploy = zeros(LogicPara.Nf, PhyPara.Ns*2);
for k = 1:length(VNF_pool)
    VNF_ind = VNF_pool(k);
    for i = 1:length(Node_pool)
        Node_ind = Node_pool(i);
        if LogicPara.RequiredFPGA(VNF_ind) <= PhyPara.FPGA_Num(Node_ind)
            x_Deploy(VNF_ind, Node_ind+PhyPara.Ns) = 1;
            PhyPara.FPGA_Num(Node_ind) = PhyPara.FPGA_Num(Node_ind) - LogicPara.RequiredFPGA(VNF_ind);
            break
        elseif LogicPara.RequiredvCPU(VNF_ind) <= PhyPara.vCPUNumMax(Node_ind)
            x_Deploy(VNF_ind, Node_ind) = 1;
            PhyPara.vCPUNumMax(Node_ind) = PhyPara.vCPUNumMax(Node_ind) - LogicPara.RequiredvCPU(VNF_ind);
            break
        end
    end
end