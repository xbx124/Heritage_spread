package org.example.heritage.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.example.heritage.common.constants.RoleConstants;
import org.example.heritage.common.constants.UserContext;
import org.example.heritage.common.exception.BusinessException;
import org.example.heritage.mapper.HeritageCategoryMapper;
import org.example.heritage.mapper.HeritageProjectMapper;
import org.example.heritage.pojo.dto.CategoryAddDTO;
import org.example.heritage.pojo.entity.HeritageCategory;
import org.example.heritage.pojo.entity.HeritageProject;
import org.example.heritage.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class CategoryServiceImpl implements CategoryService {

    @Autowired
    private HeritageCategoryMapper categoryMapper;

    @Autowired
    private HeritageProjectMapper projectMapper;

    @Override
    public List<HeritageCategory> listByPage(Integer page, Integer size) {
        page = normalizePage(page);
        size = normalizeSize(size);
        Integer offset = (page - 1) * size;
        return categoryMapper.selectCategoryPage(offset, size);
    }

    @Override
    public Long count() {
        return categoryMapper.countCategoryPage();
    }

    @Override
    public Integer add(CategoryAddDTO dto) {
        checkAdmin();

        Long count = categoryMapper.selectCount(
                new LambdaQueryWrapper<HeritageCategory>()
                        .eq(HeritageCategory::getCategoryName, dto.getCategoryName())
        );

        if (count != null && count > 0) {
            throw new BusinessException(409, "分类名称已存在");
        }

        HeritageCategory category = new HeritageCategory();
        category.setCategoryName(dto.getCategoryName());
        category.setCategoryDesc(dto.getCategoryDesc());
        LocalDateTime now = LocalDateTime.now();
        Integer currentUserId = getCurrentUserId();
        category.setCreateTime(now);
        category.setUpdateTime(now);
        category.setCreateId(currentUserId);
        category.setUpdateId(currentUserId);

        categoryMapper.insert(category);
        return category.getCategoryId();
    }

    @Override
    public void update(Integer categoryId, CategoryAddDTO dto) {
        checkAdmin();

        HeritageCategory category = categoryMapper.selectById(categoryId);
        if (category == null) {
            throw new BusinessException(404, "分类不存在");
        }

        Long duplicateCount = categoryMapper.selectCount(
                new LambdaQueryWrapper<HeritageCategory>()
                        .eq(HeritageCategory::getCategoryName, dto.getCategoryName())
                        .ne(HeritageCategory::getCategoryId, categoryId)
        );
        if (duplicateCount != null && duplicateCount > 0) {
            throw new BusinessException(409, "分类名称已存在");
        }

        category.setCategoryName(dto.getCategoryName());
        category.setCategoryDesc(dto.getCategoryDesc());
        category.setUpdateTime(LocalDateTime.now());
        category.setUpdateId(getCurrentUserId());

        categoryMapper.updateById(category);
    }

    @Override
    public void delete(Integer categoryId) {
        checkAdmin();

        HeritageCategory category = categoryMapper.selectById(categoryId);
        if (category == null) {
            throw new BusinessException(404, "分类不存在");
        }

        Long projectCount = projectMapper.selectCount(
                new LambdaQueryWrapper<HeritageProject>()
                        .eq(HeritageProject::getCategoryId, categoryId)
        );
        if (projectCount != null && projectCount > 0) {
            throw new BusinessException(409, "该分类下存在非遗项目，无法删除");
        }

        categoryMapper.deleteById(categoryId);
    }

    private void checkAdmin() {
        if (!RoleConstants.ADMIN.equals(UserContext.getCurrentRole())) {
            throw new BusinessException(403, "权限不足");
        }
    }

    private Integer getCurrentUserId() {
        Long userId = UserContext.getCurrentUserId();
        return userId == null ? null : userId.intValue();
    }

    private Integer normalizePage(Integer page) {
        return page == null || page < 1 ? 1 : page;
    }

    private Integer normalizeSize(Integer size) {
        if (size == null || size < 1) {
            return 10;
        }
        return Math.min(size, 50);
    }
}