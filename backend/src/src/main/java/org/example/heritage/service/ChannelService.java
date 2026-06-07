package org.example.heritage.service;

import org.example.heritage.pojo.dto.ChannelAddDTO;
import org.example.heritage.pojo.vo.ChannelVO;

import java.util.List;

public interface ChannelService {

    List<ChannelVO> list();

    Integer add(ChannelAddDTO dto);

    void update(Integer channelId, ChannelAddDTO dto, Integer status);

    void delete(Integer channelId);
}