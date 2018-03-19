%_author: Luiz Claudio Navarro (MSc student)
%_organization: UNICAMP - University of Campinas - Campinas - SP - Brazil
%_version/date: v1.0.1r0/2017.09.16
%_application: CTGF Features mapping

function [rnk_str, feat_type] = CTGFmap_Rank_Type(rnk_type)

CTGFmap_IncludeConstants;

switch rnk_type
    case RNK_NO
        rnk_str = 'No';
        feat_type = 'no';
    case RNK_ALL_DVGSUP
        rnk_str = 'AllDvgSup';
        feat_type = 'all';
    case RNK_ALL_RNDFOR
        rnk_str = 'AllRndFor';
        feat_type = 'all';
    case RNK_POS_DVGSUP
        rnk_str = 'PosDvgSup';
        feat_type = 'positive';
    case RNK_POS_RNDFOR
        rnk_str = 'PosRndFor';
        feat_type = 'positive';
    case RNK_NEG_DVGSUP
        rnk_str = 'NegDvgSup';
        feat_type = 'negative';
    case RNK_NEG_RNDFOR
        rnk_str = 'NegRndFor';
        feat_type = 'negative';
    otherwise
        error(['!!!Error: Invalid ranking type: ', num2str(rnk_type), '!']); 
end

end