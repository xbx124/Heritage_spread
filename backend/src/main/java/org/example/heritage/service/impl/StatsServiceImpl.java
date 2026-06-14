package org.example.heritage.service.impl;

import org.example.heritage.common.constants.RoleConstants;
import org.example.heritage.common.constants.UserContext;
import org.example.heritage.common.exception.BusinessException;
import org.example.heritage.mapper.HeritageProjectMapper;
import org.example.heritage.mapper.SpreadChannelMapper;
import org.example.heritage.mapper.SpreadDataMapper;
import org.example.heritage.pojo.dto.SpreadDataUpdateDTO;
import org.example.heritage.pojo.entity.HeritageProject;
import org.example.heritage.pojo.entity.SpreadChannel;
import org.example.heritage.pojo.entity.SpreadData;
import org.example.heritage.pojo.vo.ChannelStatsVO;
import org.example.heritage.pojo.vo.ProjectStatsVO;
import org.example.heritage.pojo.vo.SpreadDataVO;
import org.example.heritage.pojo.vo.TrendDataVO;
import org.example.heritage.service.StatsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class StatsServiceImpl implements StatsService {

    @Autowired
    private SpreadChannelMapper channelMapper;

    @Autowired
    private HeritageProjectMapper projectMapper;

    @Autowired
    private SpreadDataMapper spreadDataMapper;

    @Override
    public List<ChannelStatsVO> channelStats() {
        return channelMapper.selectChannelStats();
    }

    @Override
    public List<SpreadDataVO> projectStatsList(Integer page, Integer size) {
        page = normalizePage(page);
        size = normalizeSize(size);
        Integer offset = (page - 1) * size;
        return spreadDataMapper.selectSpreadDataList(offset, size);
    }

    @Override
    public Long countProjectStatsList() {
        return spreadDataMapper.countSpreadDataList();
    }

    @Override
    public ProjectStatsVO projectStats(Integer projectId) {
        HeritageProject project = projectMapper.selectById(projectId);
        if (project == null || project.getStatus() == null || project.getStatus() != 1) {
            throw new BusinessException(404, "项目不存在或已下架");
        }
        ProjectStatsVO vo = projectMapper.selectProjectStats(projectId);
        if (vo == null) {
            throw new BusinessException(404, "项目不存在或暂无统计数据");
        }
        return vo;
    }

    @Override
    public List<TrendDataVO> trend(Integer projectId) {
        HeritageProject project = projectMapper.selectById(projectId);
        if (project == null || project.getStatus() == null || project.getStatus() != 1) {
            throw new BusinessException(404, "项目不存在或已下架");
        }
        return spreadDataMapper.selectProjectTrend(projectId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void record(SpreadDataUpdateDTO dto) {
        checkAdmin();

        HeritageProject project = projectMapper.selectById(dto.getProjectId());
        if (project == null || project.getStatus() == null || project.getStatus() != 1) {
            throw new BusinessException(404, "项目不存在或已下架");
        }

        SpreadChannel channel = channelMapper.selectById(dto.getChannelId());
        if (channel == null) {
            throw new BusinessException(404, "渠道不存在");
        }
        if (channel.getStatus() == null || channel.getStatus() != 1) {
            throw new BusinessException(400, "渠道已禁用，无法录入传播数据");
        }

        LocalDateTime now = LocalDateTime.now();
        Integer currentUserId = getCurrentUserId();

        SpreadData spreadData = new SpreadData();
        spreadData.setProjectId(dto.getProjectId());
        spreadData.setChannelId(dto.getChannelId());
        spreadData.setViewNum(dto.getViewNum());
        spreadData.setExposureNum(dto.getExposureNum());
        spreadData.setStatTime(resolveStatTime(dto, now));
        spreadData.setCreateTime(now);
        spreadData.setUpdateTime(now);
        spreadData.setCreateId(currentUserId);
        spreadData.setUpdateId(currentUserId);

        spreadDataMapper.insert(spreadData);
    }

    private LocalDateTime resolveStatTime(SpreadDataUpdateDTO dto, LocalDateTime now) {
        if (dto.getStatTime() != null) {
            return dto.getStatTime();
        }
        if (dto.getDate() != null) {
            return dto.getDate().atStartOfDay();
        }
        return now;
    }

    private Integer normalizePage(Integer page) {
        return page == null || page < 1 ? 1 : page;
    }

    private Integer normalizeSize(Integer size) {
        if (size == null || size < 1) {
            return 10;
        }
        return Math.min(size, 100);
    }

    private Integer getCurrentUserId() {
        Long userId = UserContext.getCurrentUserId();
        return userId == null ? null : userId.intValue();
    }

    private void checkAdmin() {
        if (!RoleConstants.ADMIN.equals(UserContext.getCurrentRole())) {
            throw new BusinessException(403, "权限不足");
        }
    }
}
