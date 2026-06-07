package org.example.heritage.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.example.heritage.common.constants.RoleConstants;
import org.example.heritage.common.constants.UserContext;
import org.example.heritage.common.exception.BusinessException;
import org.example.heritage.mapper.SpreadChannelMapper;
import org.example.heritage.pojo.dto.ChannelAddDTO;
import org.example.heritage.pojo.entity.SpreadChannel;
import org.example.heritage.pojo.vo.ChannelVO;
import org.example.heritage.service.ChannelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ChannelServiceImpl implements ChannelService {

    @Autowired
    private SpreadChannelMapper channelMapper;

    @Override
    public List<ChannelVO> list() {
        boolean includeDisabled = RoleConstants.ADMIN.equals(UserContext.getCurrentRole());
        return channelMapper.selectChannelList(includeDisabled);
    }

    @Override
    public Integer add(ChannelAddDTO dto) {
        checkAdmin();
        checkChannelNameDuplicate(dto.getChannelName(), null);

        SpreadChannel channel = new SpreadChannel();
        channel.setChannelName(dto.getChannelName());
        channel.setChannelType(dto.getChannelType());
        channel.setStatus(1);
        LocalDateTime now = LocalDateTime.now();
        Integer currentUserId = getCurrentUserId();
        channel.setCreateTime(now);
        channel.setUpdateTime(now);
        channel.setCreateId(currentUserId);
        channel.setUpdateId(currentUserId);

        channelMapper.insert(channel);
        return channel.getChannelId();
    }

    @Override
    public void update(Integer channelId, ChannelAddDTO dto, Integer status) {
        checkAdmin();

        SpreadChannel channel = channelMapper.selectById(channelId);
        if (channel == null) {
            throw new BusinessException(404, "渠道不存在");
        }

        checkChannelNameDuplicate(dto.getChannelName(), channelId);

        channel.setChannelName(dto.getChannelName());
        channel.setChannelType(dto.getChannelType());

        if (status != null) {
            if (status != 0 && status != 1) {
                throw new BusinessException(400, "渠道状态只能是0或1");
            }
            channel.setStatus(status);
        }
        channel.setUpdateTime(LocalDateTime.now());
        channel.setUpdateId(getCurrentUserId());

        channelMapper.updateById(channel);
    }

    @Override
    public void delete(Integer channelId) {
        checkAdmin();

        SpreadChannel channel = channelMapper.selectById(channelId);
        if (channel == null) {
            throw new BusinessException(404, "渠道不存在");
        }

        channel.setStatus(0);
        channel.setUpdateTime(LocalDateTime.now());
        channel.setUpdateId(getCurrentUserId());
        channelMapper.updateById(channel);
    }

    private Integer getCurrentUserId() {
        Long userId = UserContext.getCurrentUserId();
        return userId == null ? null : userId.intValue();
    }

    private void checkChannelNameDuplicate(String channelName, Integer excludeChannelId) {
        LambdaQueryWrapper<SpreadChannel> wrapper = new LambdaQueryWrapper<SpreadChannel>()
                .eq(SpreadChannel::getChannelName, channelName);
        if (excludeChannelId != null) {
            wrapper.ne(SpreadChannel::getChannelId, excludeChannelId);
        }

        Long count = channelMapper.selectCount(wrapper);
        if (count != null && count > 0) {
            throw new BusinessException(409, "渠道名称已存在");
        }
    }

    private void checkAdmin() {
        if (!RoleConstants.ADMIN.equals(UserContext.getCurrentRole())) {
            throw new BusinessException(403, "权限不足");
        }
    }
}

