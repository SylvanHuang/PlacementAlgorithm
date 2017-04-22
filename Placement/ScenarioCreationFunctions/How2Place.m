% ��������õ�Node candidate�����ѡ���Ƿ���Բ���
% NOTE: �����Ǽ���ʱ��
function [Node2Place, PlaceSuccessful, PhyPara] = How2Place(LogicPara, PhyPara, Ordered_Node4Placement, VNF_Ind)
PlaceSuccessful = 0; % �ж��Ƿ���ɹ�
Node2Place = 0;
for Node_Ind_tmp = Ordered_Node4Placement
    vCPU_Num = PhyPara.vCPUNumMax(Node_Ind_tmp);
    FPGA_Num = PhyPara.FPGA_Num(Node_Ind_tmp);
    Required_vCPU = LogicPara.RequiredvCPU(VNF_Ind);
    Required_FPGA = LogicPara.RequiredFPGA(VNF_Ind);
    Ratio_vCPU = Required_vCPU/vCPU_Num;
    Ratio_FPGA = Required_FPGA/FPGA_Num;
    if Ratio_vCPU>1 && Ratio_FPGA>1
        % �޿�����Դ
        continue
    else
        switch Ratio_vCPU < Ratio_FPGA
            case 1
                % Ӧ�����Ȳ�����vCPU
                PhyPara.vCPUNumMax(Node_Ind_tmp) = vCPU_Num - Required_vCPU;
                Node2Place = Node_Ind_tmp;
            case 0
                % Ӧ�����Ȳ�����FPGA
                PhyPara.FPGA_Num(Node_Ind_tmp) = FPGA_Num - Required_FPGA;
                Node2Place = PhyPara.Ns + Node_Ind_tmp;
        end
        
        PlaceSuccessful = 1;
        break
    end
end