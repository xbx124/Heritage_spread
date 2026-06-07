package org.example.heritage.service.impl;

import org.example.heritage.common.constants.RoleConstants;
import org.example.heritage.common.constants.UserContext;
import org.example.heritage.common.exception.BusinessException;
import org.example.heritage.mapper.HeritageCategoryMapper;
import org.example.heritage.mapper.HeritageInheritorMapper;
import org.example.heritage.mapper.HeritageProjectMapper;
import org.example.heritage.pojo.dto.InheritorAddDTO;
import org.example.heritage.pojo.dto.InheritorQueryDTO;
import org.example.heritage.pojo.dto.ProjectAddDTO;
import org.example.heritage.pojo.dto.ProjectPageQueryDTO;
import org.example.heritage.pojo.entity.HeritageInheritor;
import org.example.heritage.pojo.entity.HeritageProject;
import org.example.heritage.pojo.vo.InheritorVO;
import org.example.heritage.pojo.vo.ProjectDetailVO;
import org.example.heritage.pojo.vo.ProjectListVO;
import org.example.heritage.service.ProjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ProjectServiceImpl implements ProjectService {

    @Autowired
    private HeritageProjectMapper projectMapper;

    @Autowired
    private HeritageInheritorMapper inheritorMapper;

    @Autowired
    private HeritageCategoryMapper categoryMapper;

    @Override
    public List<ProjectListVO> list(ProjectPageQueryDTO query) {
        normalizeQuery(query);
        return projectMapper.selectProjectList(query);
    }

    @Override
    public Long count(ProjectPageQueryDTO query) {
        normalizeQuery(query);
        return projectMapper.countProjectList(query);
    }

    @Override
    public ProjectDetailVO detail(Integer projectId) {
        ProjectDetailVO detail = projectMapper.selectProjectDetail(projectId);
        if (detail == null) {
            throw new BusinessException(404, "项目不存在");
        }

        InheritorQueryDTO query = new InheritorQueryDTO();
        query.setProjectId(projectId);
        query.setPage(1);
        query.setSize(100);

        List<InheritorVO> inheritors = inheritorMapper.selectInheritorList(query);
        detail.setInheritors(inheritors);

        return detail;
    }

    @Override
    @Transactional
    public Integer add(ProjectAddDTO dto) {
        checkEditorOrAdmin();
        checkCategoryExists(dto.getCategoryId());

        HeritageProject project = new HeritageProject();
        project.setProjectName(dto.getProjectName());
        project.setCategoryId(dto.getCategoryId());
        project.setArea(dto.getArea());
        project.setProjectIntro(dto.getProjectIntro());
        LocalDateTime now = LocalDateTime.now();
        Integer currentUserId = getCurrentUserId();
        project.setStatus(1);
        project.setCreateTime(now);
        project.setUpdateTime(now);
        project.setCreateId(currentUserId);
        project.setUpdateId(currentUserId);

        projectMapper.insert(project);

        if (dto.getInheritors() != null && !dto.getInheritors().isEmpty()) {
            for (InheritorAddDTO item : dto.getInheritors()) {
                HeritageInheritor inheritor = new HeritageInheritor();
                inheritor.setName(item.getName());
                inheritor.setProjectId(project.getProjectId());
                inheritor.setYears(item.getYears());
                inheritor.setIntro(item.getIntro());
                inheritor.setAvatar(item.getAvatar());
                inheritor.setStatus(1);
                inheritor.setCreateTime(now);
                inheritor.setUpdateTime(now);
                inheritor.setCreateId(currentUserId);
                inheritor.setUpdateId(currentUserId);
                inheritorMapper.insert(inheritor);
            }
        }

        return project.getProjectId();
    }

    @Override
    public void update(Integer projectId, ProjectAddDTO dto) {
        checkEditorOrAdmin();

        HeritageProject project = projectMapper.selectById(projectId);
        if (project == null) {
            throw new BusinessException(404, "项目不存在");
        }

        checkCategoryExists(dto.getCategoryId());

        project.setProjectName(dto.getProjectName());
        project.setCategoryId(dto.getCategoryId());
        project.setArea(dto.getArea());
        project.setProjectIntro(dto.getProjectIntro());
        project.setUpdateTime(LocalDateTime.now());
        project.setUpdateId(getCurrentUserId());

        projectMapper.updateById(project);
    }

    @Override
    @Transactional
    public void delete(Integer projectId) {
        checkAdmin();

        HeritageProject project = projectMapper.selectById(projectId);
        if (project == null) {
            throw new BusinessException(404, "项目不存在");
        }

        LocalDateTime now = LocalDateTime.now();
        Integer currentUserId = getCurrentUserId();

        project.setStatus(0);
        project.setUpdateTime(now);
        project.setUpdateId(currentUserId);
        projectMapper.updateById(project);

        List<HeritageInheritor> inheritors = inheritorMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<HeritageInheritor>()
                        .eq(HeritageInheritor::getProjectId, projectId)
                        .eq(HeritageInheritor::getStatus, 1)
        );
        for (HeritageInheritor inheritor : inheritors) {
            inheritor.setStatus(0);
            inheritor.setUpdateTime(now);
            inheritor.setUpdateId(currentUserId);
            inheritorMapper.updateById(inheritor);
        }
    }

    private Integer getCurrentUserId() {
        Long userId = UserContext.getCurrentUserId();
        return userId == null ? null : userId.intValue();
    }

    private void checkCategoryExists(Integer categoryId) {
        if (categoryId == null || categoryMapper.selectById(categoryId) == null) {
            throw new BusinessException(404, "分类不存在");
        }
    }

    private void normalizeQuery(ProjectPageQueryDTO query) {
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