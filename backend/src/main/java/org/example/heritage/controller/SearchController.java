package org.example.heritage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.heritage.common.result.Result;
import org.example.heritage.pojo.vo.SearchVO;
import org.example.heritage.service.SearchService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "全局搜索模块")
@Slf4j
@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @Operation(summary = "全局搜索")
    @GetMapping
    public Result<List<SearchVO>> search(@RequestParam(required = false) String keyword) {
        log.info("全局搜索开始，keyword={}", keyword);
        List<SearchVO> list = searchService.search(keyword);
        log.info("全局搜索成功，keyword={}, size={}", keyword, list == null ? 0 : list.size());
        return Result.success(list);
    }
}
