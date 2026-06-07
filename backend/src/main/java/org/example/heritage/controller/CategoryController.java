package org.example.heritage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.heritage.common.result.PageResult;
import org.example.heritage.common.result.Result;
import org.example.heritage.pojo.dto.CategoryAddDTO;
import org.example.heritage.pojo.entity.HeritageCategory;
import org.example.heritage.service.CategoryService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "非遗分类模块")
@Slf4j
@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    @Operation(summary = "分页查询分类")
    @GetMapping
    public Result<PageResult<HeritageCategory>> page(@RequestParam(defaultValue = "1") Integer page,
                                                     @RequestParam(defaultValue = "10") Integer size) {
        page = normalizePage(page);
        size = normalizeSize(size);
        log.info("分页查询分类开始，page={}, size={}", page, size);
        List<HeritageCategory> list = categoryService.listByPage(page, size);
        Long total = categoryService.count();
        log.info("分页查询分类成功，total={}, currentSize={}", total, list == null ? 0 : list.size());
        return Result.success(new PageResult<>(list, total, page, size));
    }

    @Operation(summary = "新增分类")
    @PostMapping
    public Result<Integer> add(@Valid @RequestBody CategoryAddDTO dto) {
        log.info("新增分类开始，categoryName={}", dto.getCategoryName());
        Integer categoryId = categoryService.add(dto);
        log.info("新增分类成功，categoryId={}", categoryId);
        return Result.success(categoryId);
    }

    @Operation(summary = "修改分类")
    @PutMapping("/{categoryId}")
    public Result<Void> update(@PathVariable Integer categoryId,
                               @Valid @RequestBody CategoryAddDTO dto) {
        log.info("修改分类开始，categoryId={}, categoryName={}", categoryId, dto.getCategoryName());
        categoryService.update(categoryId, dto);
        log.info("修改分类成功，categoryId={}", categoryId);
        return Result.success();
    }

    @Operation(summary = "删除分类")
    @DeleteMapping("/{categoryId}")
    public Result<Void> delete(@PathVariable Integer categoryId) {
        log.info("删除分类开始，categoryId={}", categoryId);
        categoryService.delete(categoryId);
        log.info("删除分类成功，categoryId={}", categoryId);
        return Result.success();
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
