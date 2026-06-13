package org.example.heritage.service.impl;

import org.example.heritage.common.constants.RoleConstants;
import org.example.heritage.common.constants.UserContext;
import org.example.heritage.common.exception.BusinessException;
import org.example.heritage.mapper.HeritageInheritorMapper;
import org.example.heritage.mapper.HeritageProjectMapper;
import org.example.heritage.pojo.dto.InheritorAddDTO;
import org.example.heritage.pojo.dto.InheritorQueryDTO;
import org.example.heritage.pojo.entity.HeritageInheritor;
import org.example.heritage.pojo.entity.HeritageProject;
import org.example.heritage.pojo.vo.InheritorVO;
import org.example.heritage.service.InheritorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class InheritorServiceImpl implements InheritorService {

    @Autowired
    private HeritageInheritorMapper inheritorMapper;

    @Autowired
    private HeritageProjectMapper projectMapper;

    @Override
    public List<InheritorVO> list(InheritorQueryDTO query) {
        normalizeQuery(query);
        return inheritorMapper.selectInheritorList(query);
    }

    @Override
    public Long count(InheritorQueryDTO query) {
        normalizeQuery(query);
        return inheritorMapper.countInheritorList(query);
    }

    @Override
    public InheritorVO detail(Integer inheritorId) {
        InheritorVO vo = inheritorMapper.selectInheritorDetail(inheritorId);
        if (vo == null) {
            throw new BusinessException(404, "传承人不存在");
        }
        return vo;
    }

    @Override
    public Integer add(InheritorAddDTO dto) {
        checkEditorOrAdmin();
        checkProjectExists(dto.getProjectId());

        HeritageInheritor inheritor = new HeritageInheritor();
        inheritor.setName(dto.getName());
        inheritor.setProjectId(dto.getProjectId());
        inheritor.setYears(dto.getYears());
        inheritor.setIntro(dto.getIntro());
        inheritor.setStatus(1);
        LocalDateTime now = LocalDateTime.now();
        Integer currentUserId = getCurrentUserId();
        inheritor.setCreateTime(now);
        inheritor.setUpdateTime(now);
        inheritor.setCreateId(currentUserId);
        inheritor.setUpdateId(currentUserId);

        inheritorMapper.insert(inheritor);
        return inheritor.getInheritorId();
    }

    @Override
    public void update(Integer inheritorId, InheritorAddDTO dto) {
        checkEditorOrAdmin();

        HeritageInheritor inheritor = inheritorMapper.selectById(inheritorId);
        if (inheritor == null) {
            throw new BusinessException(404, "传承人不存在");
        }

        checkProjectExists(dto.getProjectId());

        inheritor.setName(dto.getName());
        inheritor.setProjectId(dto.getProjectId());
        inheritor.setYears(dto.getYears());
        inheritor.setIntro(dto.getIntro());
        inheritor.setUpdateTime(LocalDateTime.now());
        inheritor.setUpdateId(getCurrentUserId());

        inheritorMapper.updateById(inheritor);
    }

    @Override
    public void delete(Integer inheritorId) {
        checkAdmin();

        HeritageInheritor inheritor = inheritorMapper.selectById(inheritorId);
        if (inheritor == null) {
            throw new BusinessException(404, "传承人不存在");
        }

        inheritor.setStatus(0);
        inheritor.setUpdateTime(LocalDateTime.now());
        inheritor.setUpdateId(getCurrentUserId());
        inheritorMapper.updateById(inheritor);
    }

    private Integer getCurrentUserId() {
        Long userId = UserContext.getCurrentUserId();
        return userId == null ? null : userId.intValue();
    }

    private void checkProjectExists(Integer projectId) {
        if (projectId == null) {
            throw new BusinessException(404, "项目不存在");
        }
        HeritageProject project = projectMapper.selectById(projectId);
        if (project == null || project.getStatus() == null || project.getStatus() != 1) {
            throw new BusinessException(404, "项目不存在或已下架");
        }
    }

    private void normalizeQuery(InheritorQueryDTO query) {
        if (query.getPage() == null || query.getPage() < 1) {
            query.setPage(1);
        }
        if (query.getSize() == null || query.getSize() < 1) {
            query.setSize(10);
        }
        if (query.getSize() > 50) {
            query.setSize(50);
        }
    }

    private void checkAdmin() {
        if (!RoleConstants.ADMIN.equals(UserContext.getCurrentRole())) {
            throw new BusinessException(403, "权限不足");
        }
    }

    private void checkEditorOrAdmin() {
        String role = UserContext.getCurrentRole();
        if (!RoleConstants.ADMIN.equals(role) && !RoleConstants.EDITOR.equals(role)) {
            throw new BusinessException(403, "权限不足");
        }
    }
}