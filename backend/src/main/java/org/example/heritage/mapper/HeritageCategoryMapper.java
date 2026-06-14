package org.example.heritage.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.example.heritage.pojo.entity.HeritageCategory;

import java.util.List;

@Mapper
public interface HeritageCategoryMapper extends BaseMapper<HeritageCategory> {

    List<HeritageCategory> selectCategoryPage(@Param("offset") Integer offset,
                                               @Param("size") Integer size);

    Long countCategoryPage();
}
