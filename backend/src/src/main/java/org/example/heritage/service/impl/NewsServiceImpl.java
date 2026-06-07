package org.example.heritage.service.impl;

import org.example.heritage.common.constants.RoleConstants;
import org.example.heritage.common.constants.UserContext;
import org.example.heritage.common.exception.BusinessException;
import org.example.heritage.mapper.HeritageNewsMapper;
import org.example.heritage.pojo.dto.CommentAddDTO;
import org.example.heritage.pojo.dto.NewsAuditDTO;
import org.example.heritage.pojo.dto.NewsPageQueryDTO;
import org.example.heritage.pojo.dto.NewsPublishDTO;
import org.example.heritage.pojo.entity.HeritageNews;
import org.example.heritage.pojo.vo.CommentVO;
import org.example.heritage.pojo.vo.NewsDetailVO;
import org.example.heritage.pojo.vo.NewsPageVO;
import org.example.heritage.service.NewsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class NewsServiceImpl implements NewsService {

    private static final String STATUS_PUBLISHED = "published";
    private static final String STATUS_DRAFT = "draft";
    private static final String STATUS_PENDING = "pending";
    private static final String STATUS_REJECTED = "rejected";
    private static final String STATUS_DELETED = "deleted";

    @Autowired
    private HeritageNewsMapper newsMapper;

    @Override
    public List<NewsPageVO> list(NewsPageQueryDTO query) {
        return newsMapper.selectNewsPage(query);
    }

    @Override
    public Long count(NewsPageQueryDTO query) {
        return newsMapper.countNewsPage(query);
    }

    @Override
    public NewsDetailVO detail(Integer newsId) {
        NewsDetailVO detail = newsMapper.selectNewsDetail(newsId);
        if (detail == null) {
            throw new BusinessException(404, "资讯不存在或未发布");
        }

        List<CommentVO> comments = newsMapper.selectComments(newsId, 0, 20);
        detail.setComments(comments);

        return detail;
    }

    @Override
    public Integer publish(NewsPublishDTO dto) {
        checkEditorOrAdmin();

        Long currentUserId = UserContext.getCurrentUserId();

        HeritageNews news = new HeritageNews();
        news.setTitle(dto.getTitle());
        news.setContent(dto.getContent());
        news.setSummary(buildSummary(dto));
        Integer currentUserIdInt = currentUserId == null ? null : currentUserId.intValue();
        LocalDateTime now = LocalDateTime.now();
        news.setUserId(currentUserIdInt);
        String status = normalizeStatus(dto.getStatus(), STATUS_PUBLISHED);
        news.setStatus(status);
        syncPublishTime(news, status, now);
        news.setCreateTime(now);
        news.setUpdateTime(now);
        news.setCreateId(currentUserIdInt);
        news.setUpdateId(currentUserIdInt);

        newsMapper.insert(news);
        return news.getNewsId();
    }

    @Override
    public void update(Integer newsId, NewsPublishDTO dto) {
        checkEditorOrAdmin();

        HeritageNews news = newsMapper.selectById(newsId);
        if (news == null) {
            throw new BusinessException(404, "资讯不存在");
        }
        if (STATUS_DELETED.equals(news.getStatus())) {
            throw new BusinessException(404, "资讯不存在或已删除");
        }

        if (RoleConstants.EDITOR.equals(UserContext.getCurrentRole()) && !isOwner(news)) {
            throw new BusinessException(403, "只能修改自己发布的资讯");
        }

        news.setTitle(dto.getTitle());
        news.setContent(dto.getContent());
        news.setSummary(buildSummary(dto));
        String status = normalizeStatus(dto.getStatus(), news.getStatus());
        news.setStatus(status);
        syncPublishTime(news, status, LocalDateTime.now());
        news.setUpdateTime(LocalDateTime.now());
        news.setUpdateId(getCurrentUserId());

        newsMapper.updateById(news);
    }

    @Override
    public void delete(Integer newsId) {
        checkEditorOrAdmin();

        HeritageNews news = newsMapper.selectById(newsId);
        if (news == null) {
            throw new BusinessException(404, "资讯不存在");
        }

        if (RoleConstants.EDITOR.equals(UserContext.getCurrentRole()) && !isOwner(news)) {
            throw new BusinessException(403, "只能删除自己发布的资讯");
        }

        news.setStatus(STATUS_DELETED);
        news.setUpdateTime(LocalDateTime.now());
        news.setUpdateId(getCurrentUserId());
        newsMapper.updateById(news);
    }

    @Override
    public void audit(Integer newsId, NewsAuditDTO dto) {
        checkAdmin();

        HeritageNews news = newsMapper.selectById(newsId);
        if (news == null) {
            throw new BusinessException(404, "资讯不存在");
        }
        if (STATUS_DELETED.equals(news.getStatus())) {
            throw new BusinessException(404, "资讯不存在或已删除");
        }

        String status = dto.getStatus();
        if (!STATUS_PUBLISHED.equals(status) && !STATUS_REJECTED.equals(status) && !STATUS_PENDING.equals(status)) {
            throw new BusinessException(400, "审核状态只能是 published、rejected、pending");
        }
        news.setStatus(status);
        syncPublishTime(news, status, LocalDateTime.now());
        news.setUpdateTime(LocalDateTime.now());
        news.setUpdateId(getCurrentUserId());
        newsMapper.updateById(news);
    }

    @Override
    public List<CommentVO> listComments(Integer newsId, Integer page, Integer size) {
        ensureNewsExists(newsId);

        page = normalizePage(page);
        size = normalizeSize(size);

        Integer offset = (page - 1) * size;
        return newsMapper.selectComments(newsId, offset, size);
    }

    @Override
    public Long countComments(Integer newsId) {
        ensureNewsExists(newsId);
        return newsMapper.countComments(newsId);
    }

    @Override
    public void addComment(Integer newsId, CommentAddDTO dto) {
        Long currentUserId = UserContext.getCurrentUserId();
        if (currentUserId == null) {
            throw new BusinessException(401, "未登录");
        }

        NewsDetailVO news = newsMapper.selectNewsDetail(newsId);
        if (news == null) {
            throw new BusinessException(404, "资讯不存在或未发布，不能评论");
        }

        newsMapper.insertComment(newsId, currentUserId.intValue(), dto.getContent());
    }

    private Integer normalizePage(Integer page) {
        return page == null || page < 1 ? 1 : page;
    }

    private Integer normalizeSize(Integer size) {
        if (size == null || size < 1) {
            return 20;
        }
        return Math.min(size, 50);
    }

    private String buildSummary(NewsPublishDTO dto) {
        if (dto.getSummary() != null && !dto.getSummary().isBlank()) {
            return dto.getSummary();
        }

        String content = dto.getContent();
        if (content == null) {
            return "";
        }

        String plainText = content.replaceAll("<[^>]+>", "");
        return plainText.length() > 100 ? plainText.substring(0, 100) : plainText;
    }

    private String normalizeStatus(String status, String defaultStatus) {
        if (status == null || status.isBlank()) {
            return defaultStatus;
        }
        if (!STATUS_PUBLISHED.equals(status) && !STATUS_DRAFT.equals(status) && !STATUS_PENDING.equals(status)) {
            throw new BusinessException(400, "资讯状态只能是 published、draft、pending");
        }
        return status;
    }

    private void syncPublishTime(HeritageNews news, String status, LocalDateTime now) {
        if (STATUS_PUBLISHED.equals(status)) {
            if (news.getPublishTime() == null) {
                news.setPublishTime(now);
            }
        } else {
            news.setPublishTime(null);
        }
    }

    private void ensureNewsExists(Integer newsId) {
        HeritageNews news = newsMapper.selectById(newsId);
        if (news == null || !STATUS_PUBLISHED.equals(news.getStatus())) {
            throw new BusinessException(404, "资讯不存在或未发布");
        }
    }

    private Integer getCurrentUserId() {
        Long userId = UserContext.getCurrentUserId();
        return userId == null ? null : userId.intValue();
    }

    private boolean isOwner(HeritageNews news) {
        Long currentUserId = UserContext.getCurrentUserId();
        return currentUserId != null
                && news.getUserId() != null
                && currentUserId.equals(news.getUserId().longValue());
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