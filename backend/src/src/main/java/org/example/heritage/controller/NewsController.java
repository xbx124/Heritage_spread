package org.example.heritage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.heritage.common.result.PageResult;
import org.example.heritage.common.result.Result;
import org.example.heritage.pojo.dto.CommentAddDTO;
import org.example.heritage.pojo.dto.NewsAuditDTO;
import org.example.heritage.pojo.dto.NewsPageQueryDTO;
import org.example.heritage.pojo.dto.NewsPublishDTO;
import org.example.heritage.pojo.vo.CommentVO;
import org.example.heritage.pojo.vo.NewsDetailVO;
import org.example.heritage.pojo.vo.NewsPageVO;
import org.example.heritage.service.NewsService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "文化资讯与评论模块")
@Slf4j
@RestController
@RequestMapping("/api/news")
@RequiredArgsConstructor
public class NewsController {

    private final NewsService newsService;

    @Operation(summary = "分页查询资讯")
    @GetMapping
    public Result<PageResult<NewsPageVO>> page(NewsPageQueryDTO query) {
        normalizePage(query);
        log.info("分页查询资讯开始，keyword={}, page={}, size={}",
                query.getKeyword(), query.getPage(), query.getSize());
        List<NewsPageVO> list = newsService.list(query);
        Long total = newsService.count(query);
        log.info("分页查询资讯成功，total={}, currentSize={}", total, list == null ? 0 : list.size());
        return Result.success(new PageResult<>(list, total, query.getPage(), query.getSize()));
    }

    @Operation(summary = "查询资讯详情")
    @GetMapping("/{newsId}")
    public Result<NewsDetailVO> detail(@PathVariable Integer newsId) {
        log.info("查询资讯详情开始，newsId={}", newsId);
        NewsDetailVO detail = newsService.detail(newsId);
        log.info("查询资讯详情成功，newsId={}", newsId);
        return Result.success(detail);
    }

    @Operation(summary = "发布资讯")
    @PostMapping
    public Result<Integer> publish(@Valid @RequestBody NewsPublishDTO dto) {
        log.info("发布资讯开始，title={}, status={}", dto.getTitle(), dto.getStatus());
        Integer newsId = newsService.publish(dto);
        log.info("发布资讯成功，newsId={}", newsId);
        return Result.success(newsId);
    }

    @Operation(summary = "修改资讯")
    @PutMapping("/{newsId}")
    public Result<Void> update(@PathVariable Integer newsId,
                               @Valid @RequestBody NewsPublishDTO dto) {
        log.info("修改资讯开始，newsId={}, title={}, status={}", newsId, dto.getTitle(), dto.getStatus());
        newsService.update(newsId, dto);
        log.info("修改资讯成功，newsId={}", newsId);
        return Result.success();
    }

    @Operation(summary = "删除资讯")
    @DeleteMapping("/{newsId}")
    public Result<Void> delete(@PathVariable Integer newsId) {
        log.info("删除资讯开始，newsId={}", newsId);
        newsService.delete(newsId);
        log.info("删除资讯成功，newsId={}", newsId);
        return Result.success();
    }

    @Operation(summary = "审核资讯")
    @PutMapping("/{newsId}/audit")
    public Result<Void> audit(@PathVariable Integer newsId,
                              @Valid @RequestBody NewsAuditDTO dto) {
        log.info("审核资讯开始，newsId={}, status={}", newsId, dto.getStatus());
        newsService.audit(newsId, dto);
        log.info("审核资讯成功，newsId={}, status={}", newsId, dto.getStatus());
        return Result.success();
    }

    @Operation(summary = "分页查询资讯评论")
    @GetMapping("/{newsId}/comments")
    public Result<PageResult<CommentVO>> comments(@PathVariable Integer newsId,
                                                  @RequestParam(defaultValue = "1") Integer page,
                                                  @RequestParam(defaultValue = "20") Integer size) {
        page = normalizePage(page);
        size = normalizeCommentSize(size);
        log.info("分页查询资讯评论开始，newsId={}, page={}, size={}", newsId, page, size);
        List<CommentVO> list = newsService.listComments(newsId, page, size);
        Long total = newsService.countComments(newsId);
        log.info("分页查询资讯评论成功，newsId={}, total={}, currentSize={}", newsId, total, list == null ? 0 : list.size());
        return Result.success(new PageResult<>(list, total, page, size));
    }

    @Operation(summary = "发布资讯评论")
    @PostMapping("/{newsId}/comments")
    public Result<Void> addComment(@PathVariable Integer newsId,
                                   @Valid @RequestBody CommentAddDTO dto) {
        log.info("发布资讯评论开始，newsId={}", newsId);
        newsService.addComment(newsId, dto);
        log.info("发布资讯评论成功，newsId={}", newsId);
        return Result.success();
    }

    private void normalizePage(NewsPageQueryDTO query) {
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

    private Integer normalizePage(Integer page) {
        return page == null || page < 1 ? 1 : page;
    }

    private Integer normalizeCommentSize(Integer size) {
        if (size == null || size < 1) {
            return 20;
        }
        return Math.min(size, 50);
    }
}
