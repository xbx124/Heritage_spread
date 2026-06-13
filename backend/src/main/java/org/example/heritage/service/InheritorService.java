package org.example.heritage.service;

import org.example.heritage.pojo.dto.InheritorAddDTO;
import org.example.heritage.pojo.dto.InheritorQueryDTO;
import org.example.heritage.pojo.vo.InheritorVO;

import java.util.List;

public interface InheritorService {

    List<InheritorVO> list(InheritorQueryDTO query);

    Long count(InheritorQueryDTO query);

    InheritorVO detail(Integer inheritorId);

    Integer add(InheritorAddDTO dto);

    void update(Integer inheritorId, InheritorAddDTO dto);

    void delete(Integer inheritorId);
}
